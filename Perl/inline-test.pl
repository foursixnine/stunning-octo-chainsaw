use Inline::Python qw(py_eval);
use 5.030;

py_eval(<<'END');

from functools import reduce
from datetime import datetime
import time, sys
import asyncio

async def square(number: int) -> int:
    return number*number


def call_pandas():
        import pandas as pd
        data = {
          "calories": [420, 380, 390],
          "duration": [50, 40, 45]
        }
        df = pd.DataFrame(data, index = ["day1", "day2", "day3"])
        print(df)

class MyClass:
    def __init__(self): self.data = {}
    def put(self, key, value):
        print("put in", key, value)
        print(datetime.fromtimestamp(time.time()))
        perl.Class.myfunction()
        print(sys.version)
        self.data[key] = value
    def get(self, key):
        try: return self.data[key]
        except KeyError: return None

result = asyncio.run(square(10))
print(result)
call_pandas()

END


package Class;

sub myfunction {
    say "Hello Perl";
};

1;
