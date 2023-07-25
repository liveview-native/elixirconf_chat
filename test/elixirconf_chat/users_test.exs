defmodule ElixirconfChat.UsersTest do
  use ElixirconfChat.DataCase

  alias ElixirconfChat.Repo
  alias ElixirconfChat.Users
  alias ElixirconfChat.Users.User

  test "get_user/1 returns a User when given a valid id" do
    {:ok, user} =
      Repo.insert(%User{
        email: "may@matyi.net",
        first_name: "May",
        last_name: "Matyi"
      })

    assert ^user = Users.get_user(user.id)
  end

  test "get_user/1 returns nil when given an invalid id" do
    assert nil == Users.get_user(0)
  end

  test "get_user_by_email/1 returns a User when given a valid email" do
    {:ok, user} =
      Repo.insert(%User{
        email: "may@matyi.net",
        first_name: "May",
        last_name: "Matyi"
      })

    assert ^user = Users.get_user_by_email(user.email)
  end

  test "get_user_by_email/1 returns `nil` when given an invalid email" do
    assert Users.get_user_by_email("rawr@dockyard.com") == nil
  end

  test "create_user/1 creates a User when given valid attributes" do
    attrs = %{
      email: "test@dockyard.com",
      first_name: "Test",
      last_name: "User"
    }

    {status, result} = Users.create_user(attrs)

    assert status == :ok
    assert result.__struct__ == User
    assert result.email == attrs.email
    assert result.first_name == attrs.first_name
    assert result.last_name == attrs.last_name
  end

  test "create_user/1 fails when missing `:email`" do
    attrs = %{
      first_name: "Test",
      last_name: "User"
    }

    {status, result} = Users.create_user(attrs)

    assert status == :error
    refute result.valid?
    assert result.errors == [email: {"can't be blank", [validation: :required]}]
  end

  test "create_user/1 fails when missing `:first_name`" do
    attrs = %{
      email: "test@dockyard.com",
      last_name: "User"
    }

    {status, result} = Users.create_user(attrs)

    assert status == :error
    refute result.valid?
    assert result.errors == [first_name: {"can't be blank", [validation: :required]}]
  end

  test "create_user/1 fails when missing `:last_name`" do
    attrs = %{
      email: "test@dockyard.com",
      first_name: "Test"
    }

    {status, result} = Users.create_user(attrs)

    assert status == :error
    refute result.valid?
    assert result.errors == [last_name: {"can't be blank", [validation: :required]}]
  end

  test "update_user/2 updates the given User with the given attributes" do
    {:ok, user} =
      Repo.insert(%User{
        email: "may@matyi.net",
        first_name: "May",
        last_name: "Matyi"
      })

    {status, updated_user} =
      Users.update_user(user, %{
        email: "test@dockyard.com",
        first_name: "Test",
        last_name: "User"
      })

    assert status == :ok
    assert updated_user.email == "test@dockyard.com"
    assert updated_user.first_name == "Test"
    assert updated_user.last_name == "User"
  end

  test "delete_user/1 deletes the given User" do
    {:ok, user} =
      Repo.insert(%User{
        email: "yeeted@dockyard.com",
        first_name: "Deleted",
        last_name: "User"
      })

    {status, deleted_user} = Users.delete_user(user)

    assert status == :ok
    assert deleted_user.id == user.id
    assert Repo.get(User, user.id) == nil
  end
end
