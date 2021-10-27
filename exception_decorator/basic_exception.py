class Exception1(BaseException):
    pass


def may_raise_exception():
    raise Exception1


def myfunc():
    try:
        may_raise_exception()
    except Exception1 as e:
        print('Exception1 occured!')


if __name__ == '__main__':
    myfunc()
