from weird.script.bar import Foo


def test_foo_fields() -> None:
    foo = Foo(name="Actor", value="Alice")

    assert foo.name == "Actor"
    assert foo.value == "Alice"
