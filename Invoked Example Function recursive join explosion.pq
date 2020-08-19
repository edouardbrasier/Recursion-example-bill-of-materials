let
  Source = #"Function recursive join explosion"(
      Table_Source, 
      Table_Source, 
      "Subpart", 
      "Part", 
      "Subpart", 
      "Quantity"
    ),
  ListofquantitiesCol = List.Select(Table.ColumnNames(Source), each Text.Contains(_, "Quantity")),
  ChangeTypeOfquantitiesCol = Table.TransformColumnTypes(Source, List.Transform(ListofquantitiesCol, each {_, type number})),
  ReplaceValuequantitiesColNullToOne = Table.ReplaceValue(ChangeTypeOfquantitiesCol, null, 1, Replacer.ReplaceValue, ListofquantitiesCol),
AgregatequantitiesCol = Table.CombineColumns(
      Table.TransformColumnTypes(
          ReplaceValuequantitiesColNullToOne, 
          List.Transform(ListofquantitiesCol, each {_, type text}), 
          "en-GB"
        ), 
      ListofquantitiesCol, 
      Combiner.CombineTextByDelimiter("*", QuoteStyle.None), 
      "AgregatequantitiesCol"
    ),
  CalculateExplodedquantities = Table.AddColumn(
      #"AgregatequantitiesCol", 
      "Final Quantities", 
      each Expression.Evaluate([AgregatequantitiesCol])
    ),
  ListofComponentCol = List.Select(Table.ColumnNames(Source),each Text.Contains(_, "Explosion") or Text.Contains(_, "Subpart")),
  AgregateComponentCol = Table.CombineColumns(
      Table.TransformColumnTypes(
          CalculateExplodedquantities, 
          List.Transform(ListofComponentCol, each {_, type text}), 
          "en-GB"
        ), 
      ListofComponentCol, 
      Combiner.CombineTextByDelimiter(",", QuoteStyle.None), 
      "AgregateComponentCol"
    ),
  #"Remove uneeded delimiter" = Table.ReplaceValue(AgregateComponentCol,",,","",Replacer.ReplaceText, {"AgregateComponentCol"}),
  #"remove last delimiter" = Table.AddColumn(
      #"Remove uneeded delimiter", 
      "remove last delimiter", 
      each 
        if Text.PositionOf([#"AgregateComponentCol"], ",", Occurrence.Last)
          = Text.Length([#"AgregateComponentCol"])
          - 1 then 
          Text.Start([#"AgregateComponentCol"], Text.Length([#"AgregateComponentCol"]) - 1)
        else 
          [#"AgregateComponentCol"]
    ),
  #"keep last component" = Table.AddColumn(
      #"remove last delimiter", 
      "Final Subpart", 
      each 
        if Text.PositionOf([remove last delimiter], ",", Occurrence.Last) = - 1 then 
          [remove last delimiter]
        else 
          Text.End(
              [remove last delimiter], 
              Text.Length([remove last delimiter])
                - Text.PositionOf([remove last delimiter], ",", Occurrence.Last)
              - 1
            )),
#"Removed Columns" = Table.RemoveColumns(#"keep last component", {"AgregateComponentCol", "AgregatequantitiesCol", "remove last delimiter"}),
#"Reordered Columns" = Table.ReorderColumns(#"Removed Columns", {"Part", "Final Subpart", "Final Quantities"}),
#"Changed Type" = Table.TransformColumnTypes(#"Reordered Columns",{{"Part", type text}, {"Final Subpart", type text}, {"Final Quantities", type number}}),
#"Sorted Rows" = Table.Sort(#"Changed Type", {{"Part", Order.Ascending}})
in
    #"Sorted Rows"
