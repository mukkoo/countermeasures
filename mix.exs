defmodule Countermeasures.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi3"

  def project do
    [app: :countermeasures,
     version: "0.0.1",
     target: @target,
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Countermeasures, []},
     applications: [:logger, :elixir_ale]]
  end

  def deps do
    [{:elixir_ale, "~> 0.5.5"}]
  end
end
