# dotfiles

パパッと楽に理想の環境を手に入れるやつ

dotfilesの展開だけではなく環境構築までを行います。環境を壊さず、OS/shellごとの差分を吸収し、(ソースを読まなくても)カスタマイズできるようにしています。既に環境が出来ているとしてもインクリメンタルにインストールできます。

# Install
好きな方法でインストールしてください。
個人的にはどれもあんまり好きではないので、良い方法があれば教えてください。

## bash

bash's Good point :thumbsup:
- ワンコマンドで環境構築できる
- 正規表現などのロジックが得意
- 何もインストールしなくても実行できる
- 標準入力を受け付けられる

bash's Bad point :thumbsdown:
- 冪等性がない

のでdotfilesを環境に応じて展開したり、ロジックを書きたいときに使います。冪等性を保持できないので、セマンティクスでまとめてansibleに任せて冪等性を保持しています。セマンティクスに依頼する条件は依存関係を包括するような独立のものと見なせる構成とします(それ以外は自由です)。sourceコマンドもここで行います。

```
curl "https://raw.githubusercontent.com/jiro4989/dotfiles/master/setup.sh" | bash
```

## Makefile

Makefile's Good point :thumbsup:
- 豊富なルールを書けてカスタマイズ性が高い

Makefile's Bad point :thumbsdown:
- 冪等性がない
- ルール同士に不明瞭な依存性があると原因の切り分けが難しい(ソースを全て読まなければならない)
- makeを入れないといけない

ので脳死でinstall/updateできるインターフェースとして使います。中身はshell scriptを実行するだけです。

```
make install
make update
```

## ansible

ansible's Good point :thumbsup:
- 冪等性がある
- ssh先でも環境構築できる
- ログが予測可能で何をしているのかわかりやすい

ansible's Bad point :thumbsdown:
- 冪等性を保持する分、カスタマイズ性が低い
- ansibleを入れないといけない

ので冪等性を持たせながら環境設定する為に使います。読者にとってフローを追うことは本質ではなく、良くないものを修正することが本質である。ファイルで依存関係を分けてtagsでセマンティクスを与えるようにした。

```
ansible-playbook playbook.yml
```

途中でfailしたり、部分的にupdateしたいときはタグを指定して実行すればよさです。

# シェル環境を変える方法

標準はzshとなります。
zsh以外も設定されます。(するかしないかは決められます)
その日の気分でシェルを変えても良いかも...？
でもそれぞれのシェルで設定しなければいけないのはめんどくさくて嫌ですね(どうにかならんのかな

## bash
chsh -s /usr/bin/bash

## zsh
chsh -s /bin/zsh

## fish
chsh -s /usr/bin/fish

