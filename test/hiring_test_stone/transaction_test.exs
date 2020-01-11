defmodule HiringTestStone.TransactionTest do
  use HiringTestStone.DataCase

  alias HiringTestStone.Transaction
  alias HiringTestStone.BankAccount

  describe "transfer" do
    alias HiringTestStone.Transaction.Transfer

    @valid_attrs %{amount: 120.5}
    @update_attrs %{amount: 456.7}
    @invalid_attrs %{amount: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{name: "some name"})
        |> BankAccount.create_user()

      user
    end

    def account_fixture(attrs \\ %{}) do
      user = user_fixture()
      {:ok, account} =
        attrs
        |> Enum.into(%{number: "7488a646-e31f-11e4-aace-600308960662", password_hash: "some password_hash", balance: 1_000})
        |> Enum.into(%{user_id: user.id})
        |> BankAccount.create_account()

      account
    end

    def transfer_fixture(attrs \\ %{}) do
      source_account = account_fixture()
      destination_account = account_fixture()
      {:ok, transfer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{source_account_id: source_account.id, destination_account_id: destination_account.id})
        |> Transaction.create_transfer()

      transfer
    end

    test "list_transfer/0 returns all transfer" do
      transfer = transfer_fixture()
      assert Transaction.list_transfer() == [transfer]
    end

    test "get_transfer!/1 returns the transfer with given id" do
      transfer = transfer_fixture()
      assert Transaction.get_transfer!(transfer.id) == transfer
    end

    test "create_transfer/1 with valid data creates a transfer" do
      source_account = account_fixture()
      destination_account = account_fixture()
      assert {:ok, %Transfer{} = transfer} =
        @valid_attrs
        |> Enum.into(%{source_account_id: source_account.id, destination_account_id: destination_account.id})
        |> Transaction.create_transfer()
      assert transfer.amount == 120.5
    end

    test "create_transfer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transaction.create_transfer(@invalid_attrs)
    end

    test "update_transfer/2 with valid data updates the transfer" do
      transfer = transfer_fixture()
      assert {:ok, %Transfer{} = transfer} = Transaction.update_transfer(transfer, @update_attrs)
      assert transfer.amount == 456.7
    end

    test "update_transfer/2 with invalid data returns error changeset" do
      transfer = transfer_fixture()
      assert {:error, %Ecto.Changeset{}} = Transaction.update_transfer(transfer, @invalid_attrs)
      assert transfer == Transaction.get_transfer!(transfer.id)
    end

    test "delete_transfer/1 deletes the transfer" do
      transfer = transfer_fixture()
      assert {:ok, %Transfer{}} = Transaction.delete_transfer(transfer)
      assert_raise Ecto.NoResultsError, fn -> Transaction.get_transfer!(transfer.id) end
    end

    test "change_transfer/1 returns a transfer changeset" do
      transfer = transfer_fixture()
      assert %Ecto.Changeset{} = Transaction.change_transfer(transfer)
    end
  end
end
