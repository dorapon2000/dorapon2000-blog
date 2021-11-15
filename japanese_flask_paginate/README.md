# 概要

「Flask-Paginateでページネーション情報を日本語化する」のサンプルコードです。
https://qiita.com/dorapon2000/items/2ee14849d45a89c61464

# 確認してる環境

```
$ python --version
Python 3.8.12

$ flask --version
Python 3.8.12
Flask 2.0.2
Werkzeug 2.0.2

$ python -c "import flask_paginate; print(flask_paginate.__version__)"
2021.10.29
```

# 起動方法

```sh
$ pip install -r requirements.txt
$ FLASK_APP=app FLASK_ENV=development flask run
```

ブラウザで http://127.0.0.1:5000/ にアクセスする。
