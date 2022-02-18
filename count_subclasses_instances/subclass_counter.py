class Parent():
    _subclasses_count = 0

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        __class__._subclasses_count += 1

    @classmethod
    @property
    def subclasses_count(cls):
        return __class__._subclasses_count

    # Python 3.8以前の場合
    @classmethod
    def get_subclasses_count_v3_8(cls):
        return __class__._subclasses_count


class ChildA(Parent):
    pass


class ChildB(Parent):
    pass


def main():
    child_a_1 = ChildA()
    child_a_2 = ChildA()
    child_a_3 = ChildA()

    print(Parent.subclasses_count)  # 2


if __name__ == '__main__':
    main()
