class Parent():
    _instances_count = 0

    def __new__(cls):
        self = super().__new__(cls)
        __class__._instances_count += 1
        return self

    @classmethod
    @property
    def instances_count(cls):
        return __class__._instances_count

    # Python 3.8以前の場合
    @classmethod
    def get_instances_count_v3_8(cls):
        return __class__._instances_count


class ChildA(Parent):
    pass


class ChildB(Parent):
    pass


def main():
    child_a_1 = ChildA()
    child_a_2 = ChildA()
    child_b = ChildB()

    print(Parent.instances_count)  # 3


if __name__ == '__main__':
    main()
