defmodule InstagrokWeb.UserLive.FollowersComponent do
  use InstagrokWeb, :live_component

  alias InstagrokWeb.Uploaders.Avatar

  def render(assigns) do
    ~H"""
    <div>
      <header class="bg-gray-50 p-2 border-b-2 rounded-t-xl">
        <h1 class="flex justify-center text-xl font-semibold capitalize"><%= @live_action %></h1>
      </header>
      
      <%= for follow <- @follows do %>
        <div class="p-4">
          <div class="flex items-center">
            <%= live_redirect to: Routes.user_profile_path(@socket, :index, follow.username) do %>
              <%= img_tag Avatar.get_thumb(follow.avatar_url, maybe_default: true), class: "w-10 h-10 rounded-full object-cover object-center" %>
            <% end %>

            <div class="ml-3">
              <%= live_redirect follow.username,
                to: Routes.user_profile_path(@socket, :index, follow.username),
                class: "font-semibold text-sm text-gray-700 hover:underline" %>
              <h6 class="font-semibold text-sm truncate text-gray-400">
                <%= follow.full_name %>
              </h6>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
