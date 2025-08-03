```go
func main() {
	for {
		m := stream.Receive()

		// FIXME: 複数のcaseに処理がまたがっている
		switch m := m.(type) {
		case StartMessage:
			// 時間のかかる処理
			// FIXME: 重いので別スレッドに逃がしたい
			twice := fetchTwiceValue(m.num)
			fmt.Println("twice", twice)
			stream.Send(twice)

		case CheckTwiceResult:
			// 確認
			fmt.Println("本当にtwiceだった！", m.result)
		}
	}
}
```

```go
func main() {
	var tx, rx chan any
	for {
		m := stream.Receive()
		switch m := m.(type) {
		case StartMessage:
			// goroutineに逃がせられる
			go checkWithClient(tx, rx)

		case CheckTwiceResult:
			rx <- m
		}
	}
}

func checkWithClient(tx, rx chan any) {
	// 時間のかかる処理
	twice := fetchTwiceValue(m.num)
	fmt.Println("twice", twice)
	stream.Send(twice)

	tx <- twice

	result := <-rx

	// 確認
	fmt.Println("本当にtwiceだった！", m.result)
}
```