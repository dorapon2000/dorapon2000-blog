import functools


class Exception0(BaseException):
    pass


class Exception1(BaseException):
    pass


class Exception2(BaseException):
    pass


class Exception3(BaseException):
    pass


def reraise(*catch_exceptions, reraise_exception):
    def decorated(f):
        @functools.wraps(f)
        def wrapped(*args, **kwargs):
            try:
                return f(*args, **kwargs)
            except catch_exceptions as e:
                print('may do something')
                raise reraise_exception
        return wrapped
    return decorated


def may_raise_exception():
    raise Exception0
    # raise Exception1
    # raise Exception2


@reraise(Exception1, Exception2, reraise_exception=Exception3)
def myfunc():
    may_raise_exception()


if __name__ == '__main__':
    myfunc()
