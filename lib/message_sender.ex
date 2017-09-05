defmodule FacebookMessenger.Sender do
  @moduledoc """
  Module responsible for communicating back to facebook messenger
  """
  require Logger

  @doc """
  sends a message to the the recepient

    * :recepient - the recepient to send the message to
    * :message - the message to send
    * :type - the type, :message, or :sender_action
  """
  @spec send(String.t, String.t, String.t) :: HTTPotion.Response.t
  def send(recepient, message, type \\ :message) do
    res = manager.post(
      url: url,
      body: json_payload(recepient, message, type)
    )
    Logger.info("response from FB #{inspect(res)}")
    res
  end

  @doc """
  creates a payload to send to facebook

    * :recepient - the recepient to send the message to
    * :message - the message to send
  """
  def payload(recepient, message, :message) do
    %{
      recipient: %{id: recepient},
      message: create_message(message)
    }
  end
  def payload(recepient, action, :sender_action) do
    %{
      recipient: %{id: recepient},
      sender_action: action
    }
  end


  @doc """
  creates a json payload to send to facebook

    * :recepient - the recepient to send the message to
    * :message - the message to send
    * :type - the type, :message, or :sender_action
  """
  def json_payload(recepient, message, type) do
    payload(recepient, message, type)
    |> Poison.encode
    |> elem(1)
  end

  @doc """
  return the url to hit to send the message
  """
  def url do
    query = "access_token=#{page_token}"
    "https://graph.facebook.com/v2.6/me/messages?#{query}"
  end

  defp create_message(%{} = message) do
      message
  end

  defp create_message(message) do
      %{text: message}
  end

  defp page_token do
    Application.get_env(:facebook_messenger, :facebook_page_token)
  end

  defp manager do
    Application.get_env(:facebook_messenger, :request_manager) || FacebookMessenger.RequestManager
  end
end
