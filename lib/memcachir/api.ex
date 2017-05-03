defmodule Memcachir.Api do
  @moduledoc """
  Memcached API implementation.
  """

  defmacro __using__(_opts) do
    quote do
      @doc """
      Gets the value associated with the key. Returns `{:error, :notfound}`
      if the given key doesn't exist.
      """
      def get(key) do
        execute(&:mcd.get/2, [key |> add_namespace])
      end

      @doc """
      Sets the key to value.
      """
      def set(key, value) do
        set(key, value, default_ttl())
      end

      @doc """
      Sets the key to value with a specified time to live.
      """
      def set(key, value, ttl) do
        execute(&:mcd.do/4, [{:set, 0, ttl}, key |> add_namespace, value])
      end

      @doc """
      Removes the item with the specified key. Returns `{:ok, :deleted}`
      """
      def delete(key) do
        execute(&:mcd.delete/2, [key |> add_namespace])
      end

      @doc """
      Returns the version of the memcached server.
      """
      def version do
        execute(&:mcd.version/1)
      end

      @doc """
      Removes all the items from the server. Returns `{:ok, :flushed}`.
      """
      def flush do
        execute(&:mcd.do/2, [:flush_all])
      end

      defp execute(fun, args \\ []) do
        :poolboy.transaction(Memcachir.Pool, fn(worker) ->
          apply(fun, [worker | args])
        end)
      end

      defp add_namespace(key) do
        case Application.get_env(:memcachir, :namespace) do
          nil -> key
          namespace -> "#{namespace}:#{key}"
        end
      end

      defp default_ttl do
        Application.get_env(:memcachir, :ttl, 0)
      end

    end
  end

end