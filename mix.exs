defmodule RedlockEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :redlock_ex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:redix, "~> 1.1"}
    ]
  end

  defp package do
    [
      name: :redlock_ex,
      maintainers: ["Santosh Kumar"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/santosh79/redlock_ex/tree/main"
      },
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      description: "A module to handle distributed locking using Redis."
    ]
  end
end
