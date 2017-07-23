defmodule PitchIn.Web.LayoutView do
  use PitchIn.Web, :view

  def meta_data(conn) do
    view = Phoenix.Controller.view_module(conn)
    template = Phoenix.Controller.view_template(conn)
    fb_id = Application.get_env(:pitch_in, :facebook_id)

    default_data = %{
      title: nil,
      description: "We are a meeting place to connect progressive volunteers of all skill levels with the local campaigns and causes they care about.",
      type: "website",
      image: "/img/logo_blue.png",
      fb_id: fb_id
    }

    data = 
      try do
        view.page_data(template, conn.assigns) || %{}
      rescue 
        _ -> %{}
      end

    data = Map.merge(default_data, data)

    render(__MODULE__, "_meta_data.html", conn: conn, data: data)
  end
end
