defmodule HiringTestStone.BankAccountTest do
  use HiringTestStone.DataCase

  alias HiringTestStone.BankAccount

  describe "users" do
    alias HiringTestStone.BankAccount.User

    @valid_attrs %{name: "some name", email: "some@email.com"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BankAccount.create_user()
      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert BankAccount.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert BankAccount.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = BankAccount.create_user(@valid_attrs)
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BankAccount.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = BankAccount.update_user(user, @update_attrs)
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = BankAccount.update_user(user, @invalid_attrs)
      assert user == BankAccount.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = BankAccount.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> BankAccount.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = BankAccount.change_user(user)
    end
  end

  describe "accounts" do
    alias HiringTestStone.BankAccount.{Account, User}

    @valid_attrs %{password: "123456", password_confirmation: "123456", balance: 1_000}
    @update_attrs %{balance: 950}
    @invalid_attrs %{password_hash: nil, balance: nil}

    def account_fixture(attrs \\ %{}) do
      user = user_fixture()
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{user_id: user.id})
        |> BankAccount.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert BankAccount.list_accounts() == [Account |> where([acc], acc.id == ^account.id) |> preload(:user) |> Repo.one()]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert BankAccount.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      user = user_fixture()
      assert {:ok, %Account{} = account} =
        @valid_attrs
        |> Enum.into(%{user_id: user.id})
        |> BankAccount.create_account()
      assert account.balance == 1000
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BankAccount.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = BankAccount.update_account(account, @update_attrs)
      assert account.balance == 950
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = BankAccount.update_account(account, @invalid_attrs)
      assert account == BankAccount.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = BankAccount.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> BankAccount.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = BankAccount.change_account(account)
    end

    test "register_bank_account/1 with valid data creates an account and a user" do
      attrs = %{
        balance: 1_000,
        password: "123456",
        password_confirmation: "123456",
        user: %{
          name: "John Doe",
          email: "johndoe@example.com"
        }
      }
      assert {:ok, %Account{} = account} = BankAccount.register_bank_account(attrs)
      assert account.user.id != nil
      assert account.id != nil
    end

    test "register_bank_account/1 with invalid data returns error changeset" do
      attrs = %{
        balance: 1_000,
        password: "123456",
        password_confirmation: "123456",
        user: %{
          name: "John Doe",
        }
      }
      assert {:error, %Ecto.Changeset{changes: %{user: %{errors: [email: _]}}}} =
        BankAccount.register_bank_account(attrs)
    end
  end
end
