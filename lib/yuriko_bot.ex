defmodule YurikoBot do
  use Trot.Router

  defp event_url, do: "https://trialbot-api.line.me/v1/events"

  post "/callback" do
    {:ok, body, _} = read_body(conn)
    body_json = Poison.decode!(body)
    content = List.first(body_json["result"])["content"]
    mid = content["from"]
    text = content["text"]

    max_lengs = 9
    fetchers = for _ <- 1..max_lengs, do: spawn_link fn ->
      YurikoBot.fetch_content()
    end

    Enum.each(0..Enum.random(0..max_lengs-1), fn(x) ->
      context = context(text)
      send Enum.at(fetchers,x), {self, mid, context}
    end)
  end

  def fetch_content do
    receive do
      {caller, mid, context} ->
        multiple_messages(mid, context)
        |> Poison.encode!
        |> send
    end
  end

  defp send(body), do: HTTPotion.post event_url, [body: body, headers: headers]

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

  defp multiple_messages(mid, {text, img}) do
    %{
      to: [mid],
      toChannel: 1383378250,
      eventType: 140177271400161403,
      content: %{
        messageNotified: 0,
        messages: [
          text_message(text),
          image_message(img, img)
        ]
      }
    }
  end

  defp text_message(text) do
    %{
      contentType: 1,
      toType: 1,
      text: text
    }
  end

  defp image_message(org_content_url, prev_img_url) do
    %{
      contentType: 2,
      toType: 2,
      originalContentUrl: org_content_url,
      previewImageUrl: prev_img_url
    }
  end
end
