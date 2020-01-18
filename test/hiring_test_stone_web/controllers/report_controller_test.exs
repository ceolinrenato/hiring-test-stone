defmodule HiringStoneWeb.ReportControllerTest do
  use HiringTestStoneWeb.ConnCase

  # @username Application.get_env(:basic_auth, :admin_auth)[:username]
  # @password Application.get_env(:basic_auth, :admin_auth)[:password]

  # defp using_basic_auth(conn, username, password) do
  #   header_content = "Basic " <> Base.encode64("#{username}:#{password}")
  #   conn |> put_req_header("authorization", header_content)
  # end

  test "show/2 responds with an error with not authorized", %{conn: conn} do
    conn
    |> get(
      Routes.report_path(
        conn,
        :show,
        2020,
        1,
        18
      )
    )
    |> response(401)
  end
end
