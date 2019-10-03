# BestestIf

A fun challenge and an otherwise bad idea.
Exploring advanced features of Elixir and OTP by implementing
a working "if" control flow statement that maintains the traditional
syntax (`if condition, do: some_action`).

Don't try this at home!

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bestest_if` to your list of dependencies in `mix.exs`.

Spoiler alert, putting this on Hex would be irresponsible; someone might be tempted to use it.

```elixir
def deps do
  [
    {:bestest_if, git: "https://github.com/jeffgrunewald/bestest_if.git"}
  ]
end
```

## Use

Once installed, you can incorporate the logic into your application,
if you so dare by including the necessary import statement in the
modules where you want to use the custom statement and then replacing your
traditional "if" keyword with the custom one provided by the import.

```
import BestestIf

...

def some_function(x) do
  if! something_about(x) do
    take_action_however_you_like
  end
end
```
