defmodule HiringTestStone.TransactionTest do
  use HiringTestStone.DataCase

  alias HiringTestStone.BankAccount
  alias HiringTestStone.Transaction

  describe "transfer" do
    alias HiringTestStone.Transaction.Transfer

    @valid_attrs %{amount: 120.5}
    @update_attrs %{amount: 456.7}
    @invalid_attrs %{amount: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{name: "some name", email: "some@email.com"})
        |> BankAccount.create_user()

      user
    end

    def account_fixture(attrs \\ %{}) do
      user = user_fixture()
      {:ok, account} =
        attrs
        |> Enum.into(%{password: "123456", balance: 1_000})
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
      assert Transaction.list_transfers() == [transfer]
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

    test "transfer_money/3 subtracts from source_account" do
      source_account = account_fixture()
      destination_account = account_fixture()
      {:ok, %{subtract_from_source_account_step: subtracted_account}} =
        Transaction.transfer_money(source_account.number, destination_account.number, source_account.balance)
      assert subtracted_account.balance == 0
    end

    test "transfer_money/3 adds to destination_account" do
      source_account = account_fixture()
      destination_account = account_fixture()
      {:ok, %{add_to_destination_account_step: increased_account}} =
        Transaction.transfer_money(source_account.number, destination_account.number, source_account.balance)
      assert increased_account.balance == destination_account.balance + source_account.balance
    end

    test "transfer_money/3 with valid conditions register a transfer transaction" do
      source_account = account_fixture()
      destination_account = account_fixture()
      {:ok, %{register_transfer_transaction_step: transfer_transaction}} =
        Transaction.transfer_money(source_account.number, destination_account.number, 1_000)
      assert Transaction.list_transfers == [transfer_transaction]
    end

    test "transfer_money/3 returns an error when source account balance is unsufficient" do
      source_account = account_fixture(%{balance: 500})
      destination_account = account_fixture()
      assert {:error, :verify_balance_step, :balance_too_low, _} = Transaction.transfer_money(source_account.number, destination_account.number, 1_000)
    end

    test "transfer_money/3 returns an error when source account is not found" do
      destination_account = account_fixture()
      assert {:error, :retrieve_source_account_step, :account_not_found, _} = Transaction.transfer_money("not_a_account", destination_account.number, 1_000)
    end

    test "transfer_money/3 returns an error when destination account is not found" do
      source_account = account_fixture()
      assert {:error, :retrieve_destination_account_step, :account_not_found, _} = Transaction.transfer_money(source_account.number, Ecto.UUID.generate, 1_000)
    end

    test "transfer_money/3 returns an error when transfer amount is not greater than 0" do
      source_account = account_fixture()
      destination_account = account_fixture()
      assert {:error, :register_transfer_transaction_step, _, _} = Transaction.transfer_money(source_account.number, destination_account.number, 0)
    end

    test "transfer_money/3 returns an error when trying to transfer to the same account" do
      source_account = account_fixture()
      assert {:error, :verify_accounts_step, :source_equal_to_destination, _} = Transaction.transfer_money(source_account.number, source_account.number, 100)
    end

    test "transfer_money/3 rollback account balance changes on error" do
      source_account = account_fixture()
      destination_account = account_fixture()
      Transaction.transfer_money(source_account.number, destination_account.number, -200)
      assert {BankAccount.get_account!(source_account.id).balance == source_account.balance}
      assert {BankAccount.get_account!(destination_account.id).balance == destination_account.balance}
    end

    test "withdraw_money/2 substracts from source_account" do
      source_account = account_fixture()
      {:ok, %{subtract_from_source_account_step: subtracted_account}}
        = Transaction.withdraw_money(source_account.number, source_account.balance)
      assert subtracted_account.balance == 0
    end

    test "withdraw_money/2 returns an error when source account balance is unsufficient" do
      source_account = account_fixture(%{balance: 500})
      assert {:error, :verify_balance_step, :balance_too_low, _} = Transaction.withdraw_money(source_account.number, 1_000)
    end

    test "withdraw_money/2 returns an error when source account is not found" do
      assert {:error, :retrieve_source_account_step, :account_not_found, _} = Transaction.withdraw_money("not a account", 500)
    end

    test "withdraw_money/2 returns an error when withdraw amount is not greater than 0" do
      source_account = account_fixture()
      assert {:error, :register_withdraw_transaction_step, _ , _} = Transaction.withdraw_money(source_account.number, 0)
    end

    test "withdraw_money/2 rollback account balance changes on error" do
      source_account = account_fixture()
      Transaction.withdraw_money(source_account.number, -200)
      assert {BankAccount.get_account!(source_account.id).balance == source_account.balance}
    end

    test "withdraw_money/2 with valid conditions register a withdraw transaction" do
      source_account = account_fixture()
      {:ok, %{register_withdraw_transaction_step: withdraw_transaction}} =
        Transaction.withdraw_money(source_account.number, source_account.balance)
      assert Transaction.list_withdraws == [withdraw_transaction]
    end
  end
end
