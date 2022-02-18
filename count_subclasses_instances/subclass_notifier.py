from abc import ABC, abstractclassmethod


class Parent(ABC):
    all_subclasses = []

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        __class__.all_subclasses.append(cls)

    @classmethod
    def notify_all_subclasses(cls):
        for subclass in __class__.all_subclasses:
            subclass.notify()

    @abstractclassmethod
    def notify(cls):
        pass


class ChildA(Parent):
    @classmethod
    def notify(cls):
        print(f'{__class__.__name__} subclass')


class ChildB(Parent):
    @classmethod
    def notify(cls):
        print(f'{__class__.__name__} subclass')


def main():
    Parent.notify_all_subclasses()


if __name__ == '__main__':
    main()
