defmodule FacebookMessenger.Referral do
  @moduledoc """
    Facebook referral structure
  """

  @derive [Poison.Encoder]
  defstruct [:ref, :source, :type]

  @type t :: %FacebookMessenger.Referral{
    ref: String.t,
    source: String.t,
    type: String.t
  }
end

defmodule FacebookMessenger.Attachment do
  @moduledoc """
  Messenger attachment structure
  """
  @derive [Poison.Encoder]
  defstruct [:type, :title, :payload, :url]

  @type t :: %FacebookMessenger.Attachment{
    type: atom,
    title: String.t,
    payload: %{},
    url: String.t
  }
end

defmodule FacebookMessenger.QuickReply do
  @moduledoc """
  Messenger quick reply structure
  """
  @derive [Poison.Encoder]
  defstruct [:content_type, :title, :payload]

  @type t :: %FacebookMessenger.QuickReply{
    content_type: String.t,
    title: String.t,
    payload: %{}
  }
end

defmodule FacebookMessenger.Message do
  @moduledoc """
  Facebook message structure
  """

  @derive [Poison.Encoder]
  defstruct [:mid, :seq, :text, :nlp, :attachments, :quick_replies, :quick_reply]

  @type t :: %FacebookMessenger.Message{
    mid: String.t,
    seq: integer,
    text: String.t,
    nlp: %{},
    attachments: [FacebookMessenger.Attachment.t],
    quick_replies: [FacebookMessenger.QuickReply.t],
    quick_reply: FacebookMessenger.QuickReply.t
  }
end

defmodule FacebookMessenger.User do
  @moduledoc """
  Facebook user structure
  """

  @derive [Poison.Encoder]
  defstruct [:id]

  @type t :: %FacebookMessenger.User{
    id: String.t
  }
end

defmodule FacebookMessenger.Optin do
  @moduledoc """
  Facebook user structure
  """

  @derive [Poison.Encoder]
  defstruct [:ref]

  @type t :: %FacebookMessenger.Optin{
    ref: String.t
  }
end

defmodule FacebookMessenger.Postback do
    @moduledoc """
    Facebook postback structure
    """

    @derive [Poison.Encoder]
    defstruct [:payload, :referral]

    @type t :: %FacebookMessenger.Postback{
        payload: String.t,
        referral: FacebookMessenger.Referral
    }
end

defmodule FacebookMessenger.AccountLinking do
  @moduledoc """
  Account linking structure
  """

  @derive [Poison.Encoder]
  defstruct [:authorization_code, :status]

  @type t :: %FacebookMessenger.AccountLinking{
    authorization_code: String.t,
    status: String.t
  }
end

defmodule FacebookMessenger.Messaging do
  @moduledoc """
  Facebook messaging structure, contains the sender, recepient and message info
  """
  @derive [Poison.Encoder]
  defstruct [:sender, :recipient, :timestamp, :message, :optin, :postback, :account_linking, :referral]

  @type t :: %FacebookMessenger.Messaging{
    sender: FacebookMessenger.User.t,
    recipient: FacebookMessenger.User.t,
    timestamp: integer,
    message: FacebookMessenger.Message.t,
    optin: FacebookMessenger.Optin.t,
    postback: FacebookMessenger.Postback.t,
    account_linking: FacebookMessenger.AccountLinking.t,
    referral: FacebookMessenger.Referral.t
  }
end

defmodule FacebookMessenger.Entry do
  @moduledoc """
  Facebook entry structure
  """
  @derive [Poison.Encoder]
  defstruct [:id, :time, :messaging]

  @type t :: %FacebookMessenger.Entry{
    id: String.t,
    messaging: FacebookMessenger.Messaging.t,
    time: integer
  }
end

defmodule FacebookMessenger.Response do
  @moduledoc """
  Facebook messenger response structure
  """

  @derive [Poison.Encoder]
  defstruct [:object, :entry]

  @doc """
  Decode a map into a `FacebookMessenger.Response`
  """
  @spec parse(map) :: FacebookMessenger.Response.t

  def parse(param) when is_map(param) do
    Poison.Decode.decode(param, as: decoding_map)
  end

  @doc """
  Decode a string into a `FacebookMessenger.Response`
  """
  @spec parse(String.t) :: FacebookMessenger.Response.t

  def parse(param) when is_binary(param) do
    Poison.decode!(param, as: decoding_map)
  end

  @doc """
  Retrun an list of message texts from a `FacebookMessenger.Response`
  """
  @spec message_texts(FacebookMessenger.Response) :: [String.t]
  def message_texts(%{entry: entries}) do
    messaging =
    Enum.flat_map(entries, &Map.get(&1, :messaging))
    |> Enum.map(&( &1 |> Map.get(:message) |> Map.get(:text)))
  end

  @doc """
  Return a list of attachments from a `FacebookMessenger.Response`
  """
  @spec message_attachments(FacebookMessenger.Response) :: [FacebookMessenger.Attachment.t]
  def message_attachments(%{entry: entries}) do
    messaging =
    Enum.flat_map(entries, &Map.get(&1, :messaging))
    |> Enum.map(&(&1 |> Map.get(:message)))
    |> Enum.flat_map(&Map.get(&1, :attachments))
  end

  @doc """
  Retrun an list of message sender Ids from a `FacebookMessenger.Response`
  """
  @spec message_senders(FacebookMessenger.Response) :: [String.t]
  def message_senders(%{entry: entries}) do
    messaging =
    Enum.flat_map(entries, &Map.get(&1, :messaging))
    |> Enum.map(&( &1 |> Map.get(:sender) |> Map.get(:id)))
  end


  defp decoding_map do
     messaging_parser =
    %FacebookMessenger.Messaging{
      "sender": %FacebookMessenger.User{},
      "recipient": %FacebookMessenger.User{},
      "message": %FacebookMessenger.Message{
        "attachments": [%FacebookMessenger.Attachment{}],
        "quick_replies": [%FacebookMessenger.QuickReply{}],
        "quick_reply": %FacebookMessenger.QuickReply{}
      },
      "optin": %FacebookMessenger.Optin{},
      "postback": %FacebookMessenger.Postback{},
      "referral": %FacebookMessenger.Referral{},
      "account_linking": %FacebookMessenger.AccountLinking{},
    }
    %FacebookMessenger.Response{
      "entry": [%FacebookMessenger.Entry{
        "messaging": [messaging_parser]
      }]}
  end

   @type t :: %FacebookMessenger.Response{
    object: String.t,
    entry: FacebookMessenger.Entry.t
  }

end
