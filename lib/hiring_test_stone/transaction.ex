defmodule HiringTestStone.Transaction do
  @moduledoc """
  The Transaction context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias HiringTestStone.BankAccount.Account
  alias HiringTestStone.Repo
  alias HiringTestStone.Transaction.Transfer

  @doc """
  Returns the list of transfer.

  ## Examples

      iex> list_transfer()
      [%Transfer{}, ...]

  """
  def list_transfers do
    Repo.all(Transfer)
  end

  @doc """
  Gets a single transfer.

  Raises `Ecto.NoResultsError` if the Transfer does not exist.

  ## Examples

      iex> get_transfer!(123)
      %Transfer{}

      iex> get_transfer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transfer!(id), do: Repo.get!(Transfer, id)

  @doc """
  Creates a transfer.

  ## Examples

      iex> create_transfer(%{field: value})
      {:ok, %Transfer{}}

      iex> create_transfer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transfer(attrs \\ %{}) do
    %Transfer{}
    |> Transfer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transfer.

  ## Examples

      iex> update_transfer(transfer, %{field: new_value})
      {:ok, %Transfer{}}

      iex> update_transfer(transfer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transfer(%Transfer{} = transfer, attrs) do
    transfer
    |> Transfer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Transfer.

  ## Examples

      iex> delete_transfer(transfer)
      {:ok, %Transfer{}}

      iex> delete_transfer(transfer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transfer(%Transfer{} = transfer) do
    Repo.delete(transfer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transfer changes.

  ## Examples

      iex> change_transfer(transfer)
      %Ecto.Changeset{source: %Transfer{}}

  """
  def change_transfer(%Transfer{} = transfer) do
    Transfer.changeset(transfer, %{})
  end

  def transfer_money(source_account_number, destination_account_number, transfer_amount) do
    Multi.new()
    |> Multi.run(:retrieve_source_account_step, retrieve_account_by_number(source_account_number))
    |> Multi.run(:retrieve_destination_account_step, retrieve_account_by_number(destination_account_number))
    |> Multi.run(:verify_balances_step, verify_balances(transfer_amount))
    |> Multi.run(:subtract_from_source_account_step, &subtract_from_source_account/2)
    |> Multi.run(:add_to_destination_account_step, &add_to_destination_account/2)
    |> Multi.run(:register_transfer_transaction_step, &register_transfer_transaction/2)
    |> Repo.transaction()
  end

  defp retrieve_account_by_number(account_number) do
    fn repo, _ ->
      case Account
      |> where([account], account.number == ^account_number)
      |> lock("FOR UPDATE")
      |> repo.one() do
        %Account{} = account -> {:ok, account}
        _ -> {:error, :account_not_found}
      end
    end
  end

  defp verify_balances(transfer_amount) do
    fn _repo, %{retrieve_source_account_step: source_account, retrieve_destination_account_step: destination_account} ->
      if source_account.balance < transfer_amount,
        do: {:error, :balance_too_low},
        else: {:ok, {source_account, destination_account, transfer_amount}}
    end
  end

  defp subtract_from_source_account(repo, %{verify_balances_step: {source_account, _, verified_amount}}) do
    source_account
    |> Account.changeset(%{balance: source_account.balance - verified_amount})
    |> repo.update()
  end

  defp add_to_destination_account(repo, %{verify_balances_step: {_, destination_account, verified_amount}}) do
    destination_account
    |> Account.changeset(%{balance: destination_account.balance + verified_amount})
    |> repo.update()
  end

  defp register_transfer_transaction(repo, %{verify_balances_step: {source_account, destination_account, verified_amount}}) do
    %Transfer{}
    |> Transfer.changeset(
      %{
        source_account_id: source_account.id,
        destination_account_id: destination_account.id,
        amount: verified_amount
      }
    )
    |> repo.insert()
  end

end
