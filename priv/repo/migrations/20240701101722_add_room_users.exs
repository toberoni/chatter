defmodule Chatter.Repo.Migrations.AddRoomUsers do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_sqlite.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:rooms) do
      add :private, :boolean, default: false
    end

    create table(:room_users, primary_key: false) do
      add :user_id, references(:users, column: :id, name: "room_users_user_id_fkey", type: :uuid),
        primary_key: true,
        null: false

      add :room_id,
          references(:rooms, column: :id, name: "room_users_room_id_fkey", type: :bigint),
          primary_key: true,
          null: false
    end

    unique_index(:room_users, [:user_id, :room_id])
  end

  def down do
    drop constraint(:room_users, "room_users_room_id_fkey")

    drop constraint(:room_users, "room_users_user_id_fkey")

    drop table(:room_users)

    alter table(:rooms) do
      remove :private
    end
  end
end
