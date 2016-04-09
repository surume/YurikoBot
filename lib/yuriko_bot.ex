defmodule YurikoBot do
  use Trot.Router

  defp eventUrl, do: "https://trialbot-api.line.me/v1/events"

  post "/callback" do
    {:ok, body, _} = read_body(conn)
    bodyJson = Poison.decode!(body)
    content = List.first(bodyJson["result"])["content"]
    mid = content["from"]
    text = content["text"]
    context = context(text)

    multipleMessages(mid, context) |> Poison.encode! |> send
  end

  defp send(body), do: HTTPotion.post eventUrl, [body: body, headers: headers]

  defp headers do
    [
      "Content-type": "application/json",
      "X-Line-ChannelID": System.get_env("LINE_CHANNEL_ID"),
      "X-Line-ChannelSecret": System.get_env("LINE_CHANNEL_SECRET"),
      "X-Line-Trusted-User-With-ACL": System.get_env("LINE_CHANNEL_MID")
    ]
  end

  defp context(text) when text == "ハイボール" do
    {
      "うぃーーーーーーーーーーーーーーー！！",
      "https://i.ytimg.com/vi/9tkDrN4j0aM/maxresdefault.jpg"
    }
  end

  defp context(_) do
    [
      {
        "はいぶぉおおおおる!",
        "http://img.ctalde.net/2011/01/110119-suntory-yositaka15.jpg"
      },
      {
        "こんにちは。由里子です。お金ください",
        "http://fukui-yukorin.com/wp-content/uploads/2013/06/img_567744_63561514_0-%E3%82%B3%E3%83%94%E3%83%BC.jpg"
      },
      {
        "ウマっ！",
        "http://i1.ytimg.com/vi/iGeEI6y26eU/maxresdefault.jpg"
      }
    ]
    |> Enum.random
  end

  defp multipleMessages(mid, {text, img}) do
    %{
      to: [mid],
      toChannel: 1383378250,
      eventType: 140177271400161403,
      content: %{
        messageNotified: 0,
        messages: [
          textMessage(text),
          imageMessage(img, img)
        ]
      }
    }
  end

  defp textMessage(text) do
    %{
      contentType: 1,
      toType: 1,
      text: text
    }
  end

  defp imageMessage(orgContentUrl, prevImgUrl) do
    %{
      contentType: 2,
      toType: 2,
      originalContentUrl: orgContentUrl,
      previewImageUrl: prevImgUrl
    }
  end
end
