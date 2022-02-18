from abc import ABC, abstractmethod


class Parent(ABC):
    all_instances = []

    def __new__(cls):
        self = super().__new__(cls)
        __class__.all_instances.append(self)
        return self

    @classmethod
    def notify_all_instances(cls):
        for instance in __class__.all_instances:
            instance.notify()

    @abstractmethod
    def notify(self):
        pass


class ChildA(Parent):
    def notify(self):
        print(f'{__class__.__name__} instance')


class ChildB(Parent):
    def notify(self):
        print(f'{__class__.__name__} instance')


def main():
    child_a_1 = ChildA()
    child_a_2 = ChildA()
    child_b = ChildB()

    Parent.notify_all_instances()


if __name__ == '__main__':
    main()
