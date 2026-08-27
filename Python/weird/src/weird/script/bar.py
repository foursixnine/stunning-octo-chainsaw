from dataclasses import dataclass


@dataclass
class Foo:
    name: str
    value: str

    def __init__(self, **kwargs) -> None:
        self.name = kwargs.get("name", "Nameless")
        self.value = kwargs.get("value", "Unvalued")

    def __repr__(self) -> str:
        return f"<Foo name={self.name} value={self.value}>"


if __name__ == "__main__":
    foo = Foo(name="Actor", value="Alice")
    print(foo)
