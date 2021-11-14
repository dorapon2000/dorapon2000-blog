from flask import Flask, render_template, request
from flask_paginate import Pagination, get_page_parameter
app = Flask(__name__)

@app.route('/')
def index():
    page = request.args.get(get_page_parameter(), type=int, default=1)
    limit = 5

    # DBアクセスのつもり
    users = search_users(page=page, limit=limit)
    user_count = count_users()

    # displaying 1 - 5 users in total 103
    # pagination = Pagination(page=page, per_page=limit, total=user_count, record_name='users', bs_version=4)

    # found 103 users, displaying 1 - 5
    # pagination = Pagination(page=page, per_page=limit, search=True, total=user_count, found=user_count, record_name='users', bs_version=4)

    # 103 ユーザー中の 1 - 5 ユーザー
    pagination = Pagination(
        page=page,
        per_page=limit,
        total=user_count,
        display_msg='<b>{total}</b> {record_name}中の <b>{start} - {end}</b> {record_name}',
        record_name='ユーザー',
        bs_version=4,
    )

    return render_template('index.html', users=users, pagination=pagination)


USER_COUNT = 103

def search_users(page=1, limit=5):
    """DBにアクセスしてユーザを取得する関数のつもり"""
    user_table = [f'ユーザー{i}' for i in range(1, USER_COUNT)]
    return user_table[(page - 1) * limit:(page * limit)]

def count_users():
    """DBにアクセスして総ユーザー数を取得する関数のつもり"""
    return USER_COUNT
