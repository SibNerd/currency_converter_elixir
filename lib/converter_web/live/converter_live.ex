defmodule ConverterWeb.ConverterLive do
  use ConverterWeb, :live_view

  alias Converter.{Convert}

  @impl true
  def mount(_params, _session, socket) do
    currencies = Convert.get_currency_infos()
    random_number = :rand.uniform(1000)
    topic = "convertion_page" <> "#{random_number}"
    ConverterWeb.Endpoint.subscribe(topic)
    socket = socket
      |> assign(:currencies, currencies)
      |> assign(:topic, topic)
      |> assign(:convertion_result, %{})
    {:ok, socket}
  end

  @impl true
  def handle_event("get_convertion", %{"converter" => %{"currency_amount" => amount, "currency_name" => name}}, socket) do
    currency = socket.assigns.currencies |> Enum.find(fn x -> x["Name"] == name end)
    value = currency["Value"]
    roubles = value * String.to_integer(amount) |> Float.round(4)
    result = %{name: name, amount: amount, roubles: roubles}
    ConverterWeb.Endpoint.broadcast(socket.assigns.topic, "convertion", result)
    {:noreply, socket}
  end
  
  @impl true
  def handle_info(%{event: "convertion", payload: result}, socket) do
    {:noreply, assign(socket, convertion_result: result)}
  end

end