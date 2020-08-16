defmodule Hangman do
  @words ['cat', 'dog', 'human', 'house', 'airplane', 'replication', 'terraformation']
  # @words ['human']
  # @numerals ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  @numerals '0123456789'

  @moduledoc """
  Documentation for `Hangman`.
  """

  defstruct [
    quiz_hidden: %{},
    quiz_filled: %{},
    mistake_count: 0,
    mistakes_max: 5
  ]
  @doc """
  To be written...
  """

  def play() do
    game_data = generate_quiz()
    {quit_code, quiz_hidden_updated, mistake_count} = player_make_guess(
      game_data.quiz_filled,
      game_data.quiz_hidden,
      game_data.mistake_count,
      game_data.mistakes_max
      )
      case quit_code do
        :won ->
          IO.puts("You won!")
          IO.write("The word is: ")
          print_quiz(quiz_hidden_updated)
          IO.puts(";\nYou made #{mistake_count} mistakes.\n")
          announce()

        :lost ->
          IO.puts("You lost!")
          IO.write("You couldn't guess the word: ")
          print_quiz(game_data.quiz_filled)
          IO.puts("")
          announce()
      end

  end

  def player_make_guess(quiz_filled, quiz_hidden, mistake_count \\ 0, mistakes_max) do
    cond do
      quiz_filled == quiz_hidden ->
        {:won, quiz_hidden, mistake_count}

      true ->
        print_quiz(quiz_hidden)
        chosen_position = player_choose_position(quiz_hidden)
        IO.puts("For position ##{chosen_position} your guess is:")
        input = IO.gets("-> ") |> String.trim() |> String.downcase() |> to_charlist()
        cond do
          length(input) == 1 and hd(input) in ?a..?z and Map.get(quiz_filled, chosen_position) == input and quiz_filled != quiz_hidden ->
            IO.puts("Your guess '#{input}' for position #{chosen_position} is correct!\n")
            quiz_hidden_updated = Map.put(quiz_hidden, chosen_position, input)
            player_make_guess(quiz_filled, quiz_hidden_updated, mistake_count, mistakes_max)

          mistake_count < mistakes_max ->
            IO.puts("Your guess '#{input}' for position #{chosen_position} is wrong!")
            IO.puts("Your current mistake count is #{mistake_count+1}")
            player_make_guess(quiz_filled, quiz_hidden, mistake_count + 1, mistakes_max)

          mistake_count == mistakes_max ->
            IO.puts("You have reached the limit of mistakes (#{mistake_count}/#{mistakes_max})")
            {:lost, quiz_hidden, mistake_count}
        end
    end
    # Map.get(quiz_filled, chosen_position) |> IO.inspect() == input
  end


  def player_choose_position(quiz_hidden) do
    IO.puts("Choose a number of letter position:")
    input = IO.gets("-> ") |> String.trim()
    input_char = to_charlist(input)
    input_int = String.to_integer(input)
    cond do
      hd(input_char) in @numerals ->
        cond do
          input_int in 1..map_size(quiz_hidden) - 2 ->
            input_int
          true ->
            player_choose_position(quiz_hidden)
        end
      true ->
        player_choose_position(quiz_hidden)
    end
  end

  def print_quiz(quiz_hidden), do:
    Enum.each(quiz_hidden, fn {_key, val} -> IO.write("#{val} ") end)


  def announce() do
    IO.puts("Welome to Hangman! \n Start new game?(y/n)")
    case IO.gets("-> ") |> String.trim() |> String.downcase() do
      "y" -> play()
      "n" -> System.halt()
      _ -> announce()
    end
  end

  def generate_quiz() do
    word = get_random_word()
    ln = length(word)
    quiz_field = Enum.reduce(0..ln-1, %{}, fn x, acc -> Map.put(acc, x, x) end)
    quiz_hidden = %{quiz_field | 0 => [List.first(word)], ln - 1 => [List.last(word)]}
    quiz_filled = form_filled_field(word, ln)
    %Hangman{quiz_filled: quiz_filled, quiz_hidden: quiz_hidden}
  end

  def form_filled_field(_word, _cntr1, acc \\ %{}, cntr2 \\ 0)
  def form_filled_field([head | tail], cntr1, acc, cntr2) when cntr2 < cntr1 do
      acc = Map.put(acc, cntr2, [head])
      form_filled_field(tail, cntr1, acc, cntr2 + 1)
  end
  def form_filled_field(_word, _cntr1, acc, _cntr2), do: acc

  def get_random_word(), do: Enum.random(@words)
end
