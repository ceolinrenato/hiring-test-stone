defmodule HiringTestStone.Transaction do
  @moduledoc """
  The Transaction context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias HiringTestStone.BankAccount.Account
  alias HiringTestStone.Repo
  alias HiringTestStone.Transaction.Transfer
  alias HiringTestStone.Transaction.Withdraw

  @transaction_schema %{
    transaction_type: :string,
    source_account: Ecto.UUID,
    destination_account: Ecto.UUID,
    amount: :float
  }

  @report_schema %{
    report_day: :integer,
    report_month: :integer,
    report_year: :integer,
    report_date: :date
  }

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

  def list_withdraws do
    Repo.all(Withdraw)
  end

  def withdraw_changeset(%{} = params) do
    {%{}, @transaction_schema}
    |> Ecto.Changeset.cast(params, [:transaction_type, :source_account, :amount])
    |> Ecto.Changeset.validate_required([:transaction_type, :source_account, :amount])
    |> Ecto.Changeset.validate_inclusion(:transaction_type, ["withdraw"])
    |> Ecto.Changeset.validate_number(:amount, greater_than: 0)
  end

  def transfer_changeset(%{} = params) do
    {%{}, @transaction_schema}
    |> Ecto.Changeset.cast(params, [
      :transaction_type,
      :source_account,
      :destination_account,
      :amount
    ])
    |> Ecto.Changeset.validate_required([
      :transaction_type,
      :source_account,
      :destination_account,
      :amount
    ])
    |> Ecto.Changeset.validate_inclusion(:transaction_type, ["transfer"])
    |> Ecto.Changeset.validate_number(:amount, greater_than: 0)
  end

  def report_changeset(%{} = params) do
    {%{}, @report_schema}
    |> Ecto.Changeset.cast(params, [
      :report_day,
      :report_month,
      :report_year
    ])
    |> Ecto.Changeset.validate_required(:report_year)
    |> put_report_date()
  end

  defp put_report_date(%Ecto.Changeset{changes: %{report_year: _} = changes} = changeset) do
    case Date.from_erl(
           {changes.report_year, changes[:report_month] || 1, changes[:report_day] || 1}
         ) do
      {:ok, date} ->
        changeset
        |> Ecto.Changeset.change(%{report_date: date})

      {:error, _} ->
        changeset
        |> Ecto.Changeset.add_error(:report_date, "invalid_date")
    end
  end

  def get_total_withdrew_amount(%{report_day: day, report_month: month, report_year: year}) do
    report_dt = Timex.to_datetime({year, month, day})
    from_dt = report_dt |> Timex.beginning_of_day()
    to_dt = report_dt |> Timex.end_of_day()

    Withdraw
    |> select([withdraw], sum(withdraw.amount))
    |> where([withdraw], withdraw.inserted_at >= ^from_dt and withdraw.inserted_at <= ^to_dt)
    |> Repo.one()
  end

  def get_total_withdrew_amount(%{report_month: month, report_year: year}) do
    report_dt = Timex.to_datetime({year, month, 1})
    from_dt = report_dt |> Timex.beginning_of_month()
    to_dt = report_dt |> Timex.end_of_month()

    Withdraw
    |> select([withdraw], sum(withdraw.amount))
    |> where([withdraw], withdraw.inserted_at >= ^from_dt and withdraw.inserted_at <= ^to_dt)
    |> Repo.one()
  end

  def get_total_withdrew_amount(%{report_year: year}) do
    report_dt = Timex.to_datetime({year, 1, 1})
    from_dt = report_dt |> Timex.beginning_of_year()
    to_dt = report_dt |> Timex.end_of_year()

    Withdraw
    |> select([withdraw], sum(withdraw.amount))
    |> where([withdraw], withdraw.inserted_at >= ^from_dt and withdraw.inserted_at <= ^to_dt)
    |> Repo.one()
  end

  def get_total_transfered_amount(%{report_day: day, report_month: month, report_year: year}) do
    report_dt = Timex.to_datetime({year, month, day})
    from_dt = report_dt |> Timex.beginning_of_day()
    to_dt = report_dt |> Timex.end_of_day()

    Transfer
    |> select([transfer], sum(transfer.amount))
    |> where([transfer], transfer.inserted_at >= ^from_dt and transfer.inserted_at <= ^to_dt)
    |> Repo.one()
  end

  def get_total_transfered_amount(%{report_month: month, report_year: year}) do
    report_dt = Timex.to_datetime({year, month, 1})
    from_dt = report_dt |> Timex.beginning_of_month()
    to_dt = report_dt |> Timex.end_of_month()

    Transfer
    |> select([transfer], sum(transfer.amount))
    |> where([transfer], transfer.inserted_at >= ^from_dt and transfer.inserted_at <= ^to_dt)
    |> Repo.one()
  end

  def get_total_transfered_amount(%{report_year: year}) do
    report_dt = Timex.to_datetime({year, 1, 1})
    from_dt = report_dt |> Timex.beginning_of_year()
    to_dt = report_dt |> Timex.end_of_year()

    Transfer
    |> select([transfer], sum(transfer.amount))
    |> where([transfer], transfer.inserted_at >= ^from_dt and transfer.inserted_at <= ^to_dt)
    |> Repo.one()
  end

  def transfer_money(source_account_number, destination_account_number, transfer_amount) do
    Multi.new()
    |> Multi.run(:retrieve_source_account_step, retrieve_account_by_number(source_account_number))
    |> Multi.run(
      :retrieve_destination_account_step,
      retrieve_account_by_number(destination_account_number)
    )
    |> Multi.run(:verify_accounts_step, &verify_accounts/2)
    |> Multi.run(:verify_balance_step, verify_balance(transfer_amount))
    |> Multi.run(:subtract_from_source_account_step, &subtract_from_source_account/2)
    |> Multi.run(:add_to_destination_account_step, &add_to_destination_account/2)
    |> Multi.run(:register_transfer_transaction_step, &register_transfer_transaction/2)
    |> Repo.transaction()
  end

  def withdraw_money(source_account_number, amount) do
    Multi.new()
    |> Multi.run(:retrieve_source_account_step, retrieve_account_by_number(source_account_number))
    |> Multi.run(:verify_balance_step, verify_balance(amount))
    |> Multi.run(:subtract_from_source_account_step, &subtract_from_source_account/2)
    |> Multi.run(:register_withdraw_transaction_step, &register_withdraw_transaction/2)
    |> Repo.transaction()
  end

  defp retrieve_account_by_number(account_number) do
    fn _repo, _ ->
      case HiringTestStone.BankAccount.get_account_by_number(account_number) do
        %Account{} = account -> {:ok, account}
        _ -> {:error, :account_not_found}
      end
    end
  end

  defp verify_balance(amount) do
    fn _repo, %{retrieve_source_account_step: source_account} ->
      if source_account.balance < amount,
        do: {:error, :balance_too_low},
        else: {:ok, {source_account, amount}}
    end
  end

  defp verify_accounts(_repo, %{
         retrieve_source_account_step: source_account,
         retrieve_destination_account_step: destination_account
       }) do
    if source_account.id == destination_account.id,
      do: {:error, :source_equal_to_destination},
      else: {:ok, {source_account, destination_account}}
  end

  defp subtract_from_source_account(repo, %{
         verify_balance_step: {source_account, verified_amount}
       }) do
    source_account
    |> Account.changeset(%{balance: source_account.balance - verified_amount})
    |> repo.update()
  end

  defp add_to_destination_account(repo, %{
         verify_balance_step: {_, verified_amount},
         retrieve_destination_account_step: destination_account
       }) do
    destination_account
    |> Account.changeset(%{balance: destination_account.balance + verified_amount})
    |> repo.update()
  end

  defp register_transfer_transaction(repo, %{
         verify_balance_step: {source_account, verified_amount},
         retrieve_destination_account_step: destination_account
       }) do
    %Transfer{}
    |> Transfer.changeset(%{
      source_account_id: source_account.id,
      destination_account_id: destination_account.id,
      amount: verified_amount
    })
    |> repo.insert()
  end

  defp register_withdraw_transaction(repo, %{
         verify_balance_step: {source_account, verified_amount}
       }) do
    %Withdraw{}
    |> Withdraw.changeset(%{
      source_account_id: source_account.id,
      amount: verified_amount
    })
    |> repo.insert()
  end
end
