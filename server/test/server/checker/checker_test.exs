defmodule Server.CheckerTest do
  use Server.DataCase

  alias Server.Checker

  describe "check_result_sets" do
    alias Server.Checker.CheckResultSet

    @valid_attrs %{results: %{}, status: 42, version: 42}
    @update_attrs %{results: %{}, status: 43, version: 43}
    @invalid_attrs %{results: nil, status: nil, version: nil}

    def check_result_set_fixture(attrs \\ %{}) do
      {:ok, check_result_set} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Checker.create_check_result_set()

      check_result_set
    end

    test "list_check_result_sets/0 returns all check_result_sets" do
      check_result_set = check_result_set_fixture()
      assert Checker.list_check_result_sets() == [check_result_set]
    end

    test "get_check_result_set!/1 returns the check_result_set with given id" do
      check_result_set = check_result_set_fixture()
      assert Checker.get_check_result_set!(check_result_set.id) == check_result_set
    end

    test "create_check_result_set/1 with valid data creates a check_result_set" do
      assert {:ok, %CheckResultSet{} = check_result_set} = Checker.create_check_result_set(@valid_attrs)
      assert check_result_set.results == %{}
      assert check_result_set.status == 42
      assert check_result_set.version == 42
    end

    test "create_check_result_set/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checker.create_check_result_set(@invalid_attrs)
    end

    test "update_check_result_set/2 with valid data updates the check_result_set" do
      check_result_set = check_result_set_fixture()
      assert {:ok, check_result_set} = Checker.update_check_result_set(check_result_set, @update_attrs)
      assert %CheckResultSet{} = check_result_set
      assert check_result_set.results == %{}
      assert check_result_set.status == 43
      assert check_result_set.version == 43
    end

    test "update_check_result_set/2 with invalid data returns error changeset" do
      check_result_set = check_result_set_fixture()
      assert {:error, %Ecto.Changeset{}} = Checker.update_check_result_set(check_result_set, @invalid_attrs)
      assert check_result_set == Checker.get_check_result_set!(check_result_set.id)
    end

    test "delete_check_result_set/1 deletes the check_result_set" do
      check_result_set = check_result_set_fixture()
      assert {:ok, %CheckResultSet{}} = Checker.delete_check_result_set(check_result_set)
      assert_raise Ecto.NoResultsError, fn -> Checker.get_check_result_set!(check_result_set.id) end
    end

    test "change_check_result_set/1 returns a check_result_set changeset" do
      check_result_set = check_result_set_fixture()
      assert %Ecto.Changeset{} = Checker.change_check_result_set(check_result_set)
    end
  end
end
