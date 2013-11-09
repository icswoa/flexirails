class ActiveRecordController < ApplicationController
  before_filter :populate_database

  def index
  end

  protected
  def ar_view
    @ar_view ||= ActiveRecordView.new(params)
  end
  helper_method :ar_view

  private
  def populate_database
    if Person.count == 0
      [["Delcie", "Pounds"],
      ["Charles", "Burtch"],
      ["Hayden", "Paterno"],
      ["Nery", "Vanwingerden"],
      ["Janey", "Leachman"],
      ["Sharda", "Rierson"],
      ["Inga", "Wilt"],
      ["Gertie", "Bannister"],
      ["Gladys", "Callery"],
      ["Roxanne", "Jeong"],
      ["Tamiko", "Cumberbatch"],
      ["Glady", "Haakenson"],
      ["Roxana", "Persons"],
      ["Zofia", "Linebaugh"],
      ["Susannah", "Laduke"],
      ["Huong", "Bass"],
      ["Kelsi", "Conine"],
      ["Petronila", "Epping"],
      ["Nakesha", "Crace"],
      ["Johnette", "Holsinger"],
      ["Richie", "Fairchild"],
      ["Page", "Abdul"],
      ["Elyse", "Romaine"],
      ["Zandra", "Vitela"],
      ["Shantelle", "Vandam"],
      ["Boris", "Sales"],
      ["Buck", "Yadon"],
      ["Shizue", "Henery"],
      ["Eleni", "Mckay"],
      ["Anjelica", "Setzer"],
      ["Rosamaria", "Snead"],
      ["Millie", "Predmore"],
      ["Erline", "Masden"],
      ["Fran", "Laughridge"],
      ["Tish", "Herrmann"],
      ["Pok", "Fitzmaurice"],
      ["Colette", "Benner"],
      ["Libby", "Hyman"],
      ["Hellen", "Choi"],
      ["Tyson", "Howard"],
      ["Beatriz", "Loy"],
      ["Cristine", "Dexter"],
      ["Yetta", "Freitag"],
      ["Lilliam", "Mcgowin"],
      ["Leonel", "Simpler"],
      ["Alleen", "Mulford"],
      ["Giuseppe", "Secord"],
      ["Risa", "Patel"],
      ["Ryann", "Pool"],
      ["Geneva", "Sipe"]].each do |(firstname, lastname)|
        Person.create(firstname: firstname, lastname: lastname)
      end
    end
  end
end