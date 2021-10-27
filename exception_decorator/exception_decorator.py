import functools


class Exception0(BaseException):
    pass


class Exception1(BaseException):
    pass


def exception1(f):
    @functools.wraps(f)
    def wrapper(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except Exception1 as e:
            print('Exception1 occured!')
    return wrapper


def may_raise_exception():
    raise Exception0
    # raise Exception1


@exception1
def myfunc():
    may_raise_exception()


if __name__ == '__main__':
    myfunc()
