# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirconfChat.Repo.insert!(%ElixirconfChat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias ElixirconfChat.Repo
alias ElixirconfChat.Chat.Room
alias ElixirconfChat.Chat.Timeslot
alias ElixirconfChat.Users.User

# Me :p
Repo.insert! %User{
  email: "may@matyi.net",
  first_name: "May",
  last_name: "Matyi"
}

# Test user
Repo.insert! %User{
  email: "tester@dockyard.com",
  first_name: "Testy",
  last_name: "Tester"
}

# Schedule
# day => [
#   {from, to, [
#     {title, presenters, opts},
#     ...
#   ]},
#   ...
# ]
schedule = %{
  # Wednesday
  ~D[2023-09-06] => [
    {~T[07:30:00.000], ~T[08:30:00.000], [
      {"Registration Reception", [], [subtitle: "Food & LIVE Music"]}
    ]},
    {~T[08:45:00.000], ~T[09:45:00.000], [
      {"Keynote", ["José Valim"], [subtitle: "Types, but at what cost?"]}
    ]},
    {~T[10:05:00.000], ~T[10:40:00.000], [
      {"Orb: Write WebAssembly with the power of Elixir", ["Patrick Smith"], []},
      {"Exploring code smells in Elixir", ["Elaine Watanabe"], []},
      {"Beyond LiveView: Getting the JavaScript you need while keeping the Elixir you love", ["Chris Nelson"], []}
    ]},
    {~T[10:50:00.000], ~T[11:25:00.000], [
      {"Building AI Apps with Elixir", ["Charlie Holtz"], []},
      {"A LiveView is a Process", ["Jason Stiebs"], []},
      {"Building a database GUI and proxy with Elixir", ["Michael St Clair"], []}
    ]},
    {~T[11:35:00.000], ~T[12:10:00.000], [
      {"Learn Stochastic Gradient Descent in 30 Minutes", ["Eric Iacutone"], []},
      {"State: A necessary Evil", ["Isaac Yonemoto"], []},
      {"Drawing to 7-color e-ink screens with Scenic and Nerves", ["Jason Axelson"], []}
    ]},
    {~T[13:30:00.000], ~T[14:05:00.000], [
      {"MLOps in Elixir: Simplifying traditional MLOps with Elixir", ["Sean Moriarity"], []},
      {"“SVG Island“: On building your own charts in Phoenix LiveView", ["Meks McClure", "Mark Keele"], []},
      {"Functional Juniors: Leveling up your New Elixir Devs", ["Savannah Manning"], []}
    ]},
    {~T[14:15:00.000], ~T[14:50:00.000], [
      {"Nx Powered Decision Trees", ["Andrés Alejos"], []},
      {"A Real Life Example of Using Meta-programming: Speeding up dynamic templates.", ["Andrew Selder"], []},
      {"Filling the Gaps in the Ecosystem", ["AJ Foster"], []}
    ]},
    {~T[15:00:00.000], ~T[15:35:00.000], [
      {"Building Embedded and Core System with Elixir for millions AI-based point of sales", ["Alfonso Gonzalez"], []},
      {"What's Going On Over There?!", ["Owen Bickford"], []},
      {"`fragment/1`: Ecto.Query's underrated superweapon", ["Alexander Webb"], []}
    ]},
    {~T[15:55:00.000], ~T[16:30:00.000], [
      {"Beacon: The next generation of CMS in Phoenix LiveView", ["Leandro Pereira"], []},
      {"The Alchemy of Elixir Teams; an Engineering Manager’s Tale", ["Sundi Myint"], []},
      {"Lessons Learned Working with `Ecto.Repo.put_dynamic_repo/1`", ["Sam McDavid"], []}
    ]},
    {~T[16:40:00.000], ~T[17:40:00.000], [
      {"Keynote", ["Brian Cardarella"], [subtitle: "LiveView Native"]}
    ]},
    {~T[07:30:00.000], ~T[08:30:00.000], [
      {"Reception", [], subtitle: "Hors D'oeuvres, Bar"}
    ]}
  ],
  # Thursday
  ~D[2023-09-07] => [
    {~T[08:00:00.000], ~T[08:30:00.000], [
      {"Registration Reception", [], subtitle: "Food & LIVE Music"}
    ]},
    {~T[08:40:00.000], ~T[09:40:00.000], [
      {"Keynote", ["Katelynn Burns"], [subtitle: "Motion Commotion: Motion Tracking with Bumblebee and Liveview"]}
    ]},
    {~T[10:00:00.000], ~T[10:35:00.000], [
      {"Exploring LiveViewNative", ["Brooklin Myers"], []},
      {"Black Box Techniques for Unit Tests", ["Jenny Bramble"], []},
      {"Scaling Teams with Kafka on the BEAM", ["Jeffery Utter"], []}
    ]},
    {~T[10:45:00.000], ~T[11:20:00.000], [
      {"Our LiveView Native Development Journey", ["David Bluestein II"], []},
      {"Keeping real-time auctions running during rollout. From white-knuckle to continuous deployments.", ["Rafal Studnicki"], []},
      {"Easy Ergonomic Telemetry in Production w/ Sibyl", ["Chris Bailey"], []}
    ]},
    {~T[11:30:00.000], ~T[12:05:00.000], [
      {"Elixir Security: a Business and Technical Perspective", ["Michael Lubas"], []},
      {"Testing async, async", ["Anthony Accomazzo"], []},
      {"Rewrite Pion in Elixir", ["Michał Śledź"], []}
    ]},
    {~T[13:30:00.000], ~T[14:05:00.000], [
      {"Ash 3.0: Better Together", ["Zach Daniel"], []},
      {"Building a globally distributed router", ["De Wet Blomerus"], []},
      {"Chess Vision!", ["Barrett Helms"], []}
    ]},
    {~T[14:15:00.000], ~T[14:50:00.000], [
      {"ECSx: A New Approach to Game Development in Elixir", ["Andrew Berrien"], []},
      {"Erlang Dist Filtering and the WhatsApp Runtime System", ["Andrew Bennett"], []},
      {"Conversational Web APIs with Phoenix Channels", ["Nicholas Scheurich"], []}
    ]},
    {~T[15:10:00.000], ~T[15:45:00.000], [
      {"Fine tuning language models with Axon", ["Toran Billups"], []},
      {"Managing a massive amount distributed Elixir nodes", ["Razvan Draghici"], []},
      {"Introducing Vox: the static site generator for Elixir lovers", ["Geoffrey Lessel"], []}
    ]},
    {~T[15:55:00.000], ~T[16:30:00.000], [
      {"Using DDD concepts to create better Phoenix Contexts", ["German Velasco"], []},
      {"Flex: Empowering Elixir with Fuzzy Logic for Real-World Solutions.", ["Aldebaran Alonso"], []},
      {"ex_cldr - Personalized Applications for a Global Audience", ["Petrus Janse van Rensburg"], []}
    ]},
    {~T[16:30:00.000], ~T[17:30:00.000], [
      {"⚡ Lightning Talks", [], []}
    ]}
  ],
  # Friday
  ~D[2023-09-08] => [
    {~T[08:30:00.000], ~T[09:05:00.000], [
      {"Beyond Technical Prowess: Competency is Not Enough", ["Miki Rezentes"], []},
      {"Handling async tasks in LiveView with style and grace", ["Chris Gregori"], []},
      {"Req - a batteries-included HTTP client for Elixir", ["Wojtek Mach"], []}
    ]},
    {~T[09:15:00.000], ~T[09:50:00.000], [
      {"Rebuilding the Plane While It’s Still Flying", ["Tyler Young"], []},
      {"Replacing React: How Liveview solved our performance problems", ["Tim Gremore"], []},
      {"Driving Performance with Req and Finch at Cars.com", ["Christian Koch"], []}
    ]},
    {~T[10:10:00.000], ~T[10:45:00.000], [
      {"Unleashing the Power of DAGs, introducing Pacer Workflow", ["Zack Kayzer", "Stephanie Lane"], []},
      {"Scaling Up Travel with Elixir", ["Kimberly Erni"], []},
      {"A11y testing a LiveView application with Excessibility", ["Andrew Moore"], []}
    ]},
    {~T[16:40:00.000], ~T[17:40:00.000], [
      {"Keynote", ["Chris McCord"], [subtitle: "Keynote"]}
    ]}
  ]
}

# Create Timeslot and Room for Hallway
pinned_timeslot = Repo.insert!(%Timeslot{
  starts_at: nil,
  ends_at: nil
})
Repo.insert!(%Room{
  title: "Hallway",
  track: 0,
  presenters: [],
  timeslot_id: pinned_timeslot.id
})

# Create Timeslots and Rooms for schedule
for {day, timeslots} <- schedule do
  for {from, to, talks} <- timeslots do
    # Timeslot
    timeslot =
      %Timeslot{}
      |> Timeslot.changeset(%{
        starts_at: DateTime.new!(day, from, "EST") |> DateTime.shift_zone!("UTC") |> DateTime.to_naive() |> NaiveDateTime.truncate(:second),
        ends_at: DateTime.new!(day, to, "EST") |> DateTime.shift_zone!("UTC") |> DateTime.to_naive() |> NaiveDateTime.truncate(:second),
        timezone: "EST"
      })
      |> Repo.insert!()

    # Timeslot Rooms
    if Enum.count(talks) > 1 do
      for {{title, speakers, opts}, index} <- Enum.with_index(talks) do
        Repo.insert!(%Room{
          title: title,
          track: index + 1,
          presenters: speakers,
          timeslot_id: timeslot.id
        })
      end
    else
      {title, speakers, opts} = List.first(talks)

      Repo.insert!(%Room{
        title: title,
        track: 0,
        presenters: speakers,
        timeslot_id: timeslot.id
      })
    end
  end
end
