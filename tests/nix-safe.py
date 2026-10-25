"""Exercise the guard without starting Nix or allocating memory."""
import importlib.util
from pathlib import Path
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location("nix_safe", Path(__file__).parents[1] / "scripts/nix-safe.py")
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


class GuardTests(unittest.TestCase):
    def test_pressure_blocks_before_nix_starts(self):
        with patch.object(guard.sys, "argv", ["nix-safe.py", "plan"]), \
             patch.object(guard.sys, "platform", "darwin"), \
             patch.object(guard, "pressure", return_value=2), \
             patch.object(guard.subprocess, "Popen") as popen:
            self.assertEqual(guard.main(), 75)
            popen.assert_not_called()

    def test_pressure_during_evaluation_cancels_its_process_group(self):
        process = Mock(pid=1234)
        process.poll.return_value = None
        process.wait.return_value = -15
        with patch.object(guard.sys, "argv", ["nix-safe.py", "plan"]), \
             patch.object(guard.sys, "platform", "darwin"), \
             patch.object(guard, "pressure", side_effect=[1, 2]), \
             patch.object(guard.Path, "exists", return_value=True), \
             patch.object(guard.subprocess, "check_output", return_value="Determinate Nix"), \
             patch.object(guard.subprocess, "Popen", return_value=process) as popen, \
             patch.object(guard.time, "sleep"), \
             patch.object(guard.os, "killpg") as killpg:
            self.assertEqual(guard.main(), 75)
            killpg.assert_called_once_with(1234, guard.signal.SIGTERM)
            args, kwargs = popen.call_args
            self.assertIn("--dry-run", args[0])
            self.assertIn("--no-update-lock-file", args[0])
            self.assertIn("max-jobs = 1", kwargs["env"]["NIX_CONFIG"])
            self.assertTrue(kwargs["start_new_session"])

    def test_check_action_keeps_all_checks_and_limits_heap(self):
        process = Mock(pid=1234)
        process.poll.return_value = 0
        process.wait.return_value = 0
        with patch.object(guard.sys, "argv", ["nix-safe.py", "check"]), \
             patch.object(guard.sys, "platform", "darwin"), \
             patch.object(guard, "pressure", return_value=1), \
             patch.object(guard.Path, "exists", return_value=True), \
             patch.object(guard.subprocess, "check_output", return_value="Determinate Nix"), \
             patch.object(guard.subprocess, "Popen", return_value=process) as popen, \
             patch.dict(guard.os.environ, {}, clear=True):
            self.assertEqual(guard.main(), 0)
            args, kwargs = popen.call_args
            self.assertEqual(args[0][1:4], ["flake", "check", "."])
            self.assertNotIn("--no-build", args[0])
            self.assertEqual(kwargs["env"]["GC_INITIAL_HEAP_SIZE"], "67108864")

    def test_warning_mode_is_explicit_and_caps_resources(self):
        process = Mock(pid=1234)
        process.poll.return_value = 0
        process.wait.return_value = 0
        with patch.object(guard.sys, "argv", ["nix-safe.py", "build", "--allow-warning", "--out-link", "/tmp/result"]), \
             patch.object(guard.sys, "platform", "darwin"), \
             patch.object(guard, "pressure", return_value=2), \
             patch.object(guard.Path, "exists", return_value=True), \
             patch.object(guard.subprocess, "check_output", return_value="Determinate Nix"), \
             patch.object(guard.subprocess, "Popen", return_value=process) as popen:
            self.assertEqual(guard.main(), 0)
            args, kwargs = popen.call_args
            self.assertIn("--out-link", args[0])
            self.assertIn("cores = 1", kwargs["env"]["NIX_CONFIG"])
            self.assertEqual(kwargs["env"]["GC_MAXIMUM_HEAP_SIZE"], "1073741824")

    def test_warning_mode_still_blocks_critical_pressure(self):
        with patch.object(guard.sys, "argv", ["nix-safe.py", "build", "--allow-warning"]), \
             patch.object(guard.sys, "platform", "darwin"), \
             patch.object(guard, "pressure", return_value=4), \
             patch.object(guard.subprocess, "Popen") as popen:
            self.assertEqual(guard.main(), 75)
            popen.assert_not_called()

    def test_explicit_heap_limit_overrides_warning_default(self):
        process = Mock(pid=1234)
        process.poll.return_value = 0
        process.wait.return_value = 0
        with patch.object(guard.sys, "argv", ["nix-safe.py", "plan", "--allow-warning", "--gc-heap-mib", "2048"]), \
             patch.object(guard.sys, "platform", "darwin"), \
             patch.object(guard, "pressure", return_value=1), \
             patch.object(guard.Path, "exists", return_value=True), \
             patch.object(guard.subprocess, "check_output", return_value="Determinate Nix"), \
             patch.object(guard.subprocess, "Popen", return_value=process) as popen:
            self.assertEqual(guard.main(), 0)
            self.assertEqual(popen.call_args.kwargs["env"]["GC_MAXIMUM_HEAP_SIZE"], "2147483648")

    def test_version_timeout_does_not_start_evaluation(self):
        with patch.object(guard.sys, "argv", ["nix-safe.py", "plan"]), \
             patch.object(guard.sys, "platform", "darwin"), \
             patch.object(guard, "pressure", return_value=1), \
             patch.object(guard.Path, "exists", return_value=True), \
             patch.object(guard.subprocess, "check_output", side_effect=guard.subprocess.TimeoutExpired("nix", 30)), \
             patch.object(guard.subprocess, "Popen") as popen:
            self.assertEqual(guard.main(), 75)
            popen.assert_not_called()

    def test_exit_during_cancellation_is_harmless(self):
        process = Mock(pid=1234)
        process.poll.return_value = None
        with patch.object(guard.os, "killpg", side_effect=ProcessLookupError):
            guard.stop(process)

    def test_evaluator_rss_and_time_limits_cancel(self):
        for elapsed, rss in [(1, "2097153"), (100, "1024")]:
            with self.subTest(elapsed=elapsed):
                process = Mock(pid=1234)
                process.poll.return_value = None
                with patch.object(guard.sys, "argv", ["nix-safe.py", "plan"]), \
                     patch.object(guard.sys, "platform", "darwin"), \
                     patch.object(guard, "pressure", return_value=1), \
                     patch.object(guard.Path, "exists", return_value=True), \
                     patch.object(guard.subprocess, "check_output", return_value="Determinate Nix"), \
                     patch.object(guard.subprocess, "Popen", return_value=process), \
                     patch.object(guard.subprocess, "run", return_value=Mock(stdout=rss)), \
                     patch.object(guard.time, "sleep"), \
                     patch.object(guard.time, "monotonic", side_effect=[0, elapsed]), \
                     patch.object(guard.os, "killpg") as killpg:
                    self.assertEqual(guard.main(), 75)
                    killpg.assert_called_once_with(1234, guard.signal.SIGTERM)


if __name__ == "__main__":
    unittest.main()
