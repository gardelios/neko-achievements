# TODO: neko_id == type in rules.yml?
defmodule Neko.Rules.BasicRule.Store do
  @moduledoc """
  Stores rules.
  """

  @rule_type "basic"

  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> load() end, name: name)
  end

  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  def load do
    Neko.Rules.Reader.read_from_file(@rule_type)
    |> Enum.map(&(Neko.Rules.BasicRule.new(&1)))
    |> calc_next_thresholds()
  end

  defp calc_next_thresholds(rules) do
    rules
    |> Enum.map(fn(x) ->
      %{x | next_threshold: next_threshold(rules, x)}
    end)
  end

  defp next_threshold(rules, rule) do
    rules
    |> Enum.filter(fn(x) ->
      x.neko_id == rule.neko_id and x.level == rule.level + 1
    end)
    |> Enum.map(&(&1.threshold))
    |> List.first()
  end
end
