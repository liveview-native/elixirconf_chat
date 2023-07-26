defmodule ElixirconfChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ElixirconfChatWeb.Telemetry,
      # Start the Ecto repository
      ElixirconfChat.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElixirconfChat.PubSub},
      # Start Finch
      {Finch, name: ElixirconfChat.Finch},
      # Start the Endpoint (http/https)
      ElixirconfChatWeb.Endpoint,
      # Start Oban job processing system
      {Oban, Application.fetch_env!(:elixirconf_chat, Oban)},
      # Start a worker by calling: ElixirconfChat.Worker.start_link(arg)
      # {ElixirconfChat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirconfChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirconfChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
