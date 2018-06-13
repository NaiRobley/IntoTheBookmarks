defmodule IntoTheBookmarks.CategoryController do
  use IntoTheBookmarks.Web, :controller

  alias IntoTheBookmarks.Category
  alias IntoTheBookmarks.Bookmark

  def index(conn, _params) do
    categories = Repo.all(from c in Category, preload: [:bookmarks, :user])
    render(conn, "index.json", categories)
  end

  def create(conn, %{"category" => category_params}) do
    IO.inspect category_params
    changeset = Category.changeset(%Category{}, category_params)

    case Repo.insert(changeset) do
      {:ok, category} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", category_path(conn, :show, category))
        |> render("show.json", category: category)
        # |> render("show.json", category: Map.put(category, :bookmarks, []))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IntoTheBookmarks.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)
    bookmarks = Repo.all(
      from bk in Bookmark,
      where: bk.category_id == ^id,
      select: bk)
    if Enum.any?(bookmarks) == true do
      render(conn, "show.json", category: Map.put(category, :bookmarks, bookmarks))
    else
      render(conn, "show.json", category: Map.put(category, :bookmarks, []))
    end
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Repo.get!(Category, id)
    changeset = Category.changeset(category, category_params)
    bookmarks = Repo.all(
      from bk in Bookmark,
      where: bk.category_id == ^id,
      select: bk)

    case Repo.update(changeset) do
      {:ok, category} ->
        render(conn, "show.json", category: Map.put(category, :bookmarks, bookmarks))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(IntoTheBookmarks.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(category)

    send_resp(conn, :no_content, "")
  end
end