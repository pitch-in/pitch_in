defmodule PitchIn.Web.PrefilledAsk do
  @defmodule """
  Data and functions for setting up prefilled asks.
  """

  alias PitchIn.Web.Ask

  @prefilled_asks [
    %{
      id: "create_website",
      name: "Create a website (one-time)",
      ask: %{
        role: "Web Developer",
        length: :one_time,
        hours: 16,
        skills: "html,css,javascript",
        description: "We need someone who can create a website for us, to highlight our campaign's best light! Sign up to develop a beautiful website tailored to our community, values and needs.",
        years_experience: 0
      }
    },
    %{
      id: "maintain_website",
      name: "Maintain/Update website (ongoing)",
      ask: %{
        role: "Web Developer",
        length: :ongoing,
        hours: 4,
        skills: "html,css",
        description: "Websites are the virtual hub of a campaign. Help us maintain and update ours!",
        years_experience: 0
      }
    },
    %{
      id: "design_email_template",
      name: "Design email template (one-time)",
      ask: %{
        role: "Web Developer",
        length: :one_time,
        hours: 4,
        skills: "html,css",
        description: "Help us create an attractive email template for all our communications",
        years_experience: 0
      }
    },
    %{
      id: "ongoing_emails",
      name: "Create ongoing emails (ongoing)",
      ask: %{
        role: "Web Developer",
        length: :ongoing,
        hours: 2,
        skills: "html,css",
        description: "We'll be sending out regular emails, and will need someone who knows a little HTML to prepare them.",
        years_experience: 0
      }
    },
    %{
      id: "third_party_apis",
      name: "Connect website with services like donation and volunteer sign-up (one-time)",
      ask: %{
        role: "Web Developer",
        length: :one_time,
        hours: 4,
        skills: "html,css,javascript,APIs",
        description: "Help update our website to connect with our donation and volunteer database, and other 3rd party services that campaigns typically use.",
        years_experience: 1
      }
    },
    %{
      id: "logo",
      name: "Create logos and graphics (one-time)",
      ask: %{
        role: "Graphic Designer",
        length: :one_time,
        hours: 3,
        skills: "digital design",
        description: "Design a logo to help us better communicate the campaign's message to voters.",
        years_experience: 1
      }
    },
    %{
      id: "event_design",
      name: "Graphics for a specific event (one-time)",
      ask: %{
        role: "Social Medial Graphic Designer",
        length: :one_time,
        hours: 1,
        skills: "digital design",
        description: "Help us design graphics for an upcoming event.",
        years_experience: 0
      }
    },
    %{
      id: "staff_designer",
      name: "Designer (ongoing)",
      ask: %{
        role: "Staff Graphic Designer",
        length: :ongoing,
        hours: 2,
        skills: "digital design,print design",
        description: "Design a logo to help us better communicate the campaign's message to voters and continue to produce graphics for social media and the web.",
        years_experience: 1
      }
    },
    %{
      id: "van_connect",
      name: "Connect VAN to Website (one-time)",
      ask: %{
        role: "Web Developer",
        length: :one_time,
        hours: 3,
        skills: "application developer,APIs,data",
        description: "Connect a our website to our voter and volunteer database using the votebuilder API.",
        years_experience: 1
      }
    },
    %{
      id: "walk_lists",
      name: "Cut voter contact walk-lists (one-time)",
      ask: %{
        role: "Data Manager",
        length: :one_time,
        hours: 2,
        skills: "data,data analyst",
        description: "Campaigns utilize direct voter contact to reach their audience. That means - knocking on doors! Help us “pull a universe” of targets and cut them into manageable walk packets for volunteers on the ground.",
        years_experience: 0
      }
    },
    %{
      id: "data_analyst",
      name: "Data analyst (ongoing)",
      ask: %{
        role: "Data Director",
        length: :one_time,
        hours: 3,
        skills: "data,data analyst,data scientist",
        description: "Help us contact the best voters by modeling voters' candidate preference and voting propensity.",
        years_experience: 1
      }
    }
  ]

  def asks_to_display do
    @prefilled_asks
  end

  def asks_to_create(ids, campaign) do
    @prefilled_asks
    |> Enum.filter_map(
      fn ask_data ->
        ask_data.id in ids
      end,
      fn ask_data ->
        campaign
        |> Ecto.build_assoc(:asks)
        |> Ask.changeset(ask_data.ask)
      end
    )
  end
end

