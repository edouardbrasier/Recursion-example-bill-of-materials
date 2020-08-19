(
  TableName as table, 
  TableMapping as table, 
  SourceColumnName as text, 
  KeyMappingColumnName as text, 
  ResultMappingColumnName as text,
  QuantityColumnName as text
) => 
  let
    Source = TableName,
    counter = 0,
    explode = (
      Source as table, 
      TableMapping as table, 
      SourceColumnName as text, 
      KeyMappingColumnName as text, 
      ResultMappingColumnName as text, 
      QuantityColumnName as text,
      counter as number
    ) => 
      let
        JoinTable = Table.NestedJoin(
            Source, 
            {SourceColumnName}, 
            TableMapping, 
            {KeyMappingColumnName}, 
            "mapping", 
            JoinKind.LeftOuter
          ),
        ExpandTable = Table.ExpandTableColumn(
             JoinTable, 
            "mapping", 
            {ResultMappingColumnName,QuantityColumnName }, 
            {"Explosion_" & Number.ToText(counter), QuantityColumnName  &"_"& Number.ToText(counter)}
          ),
        counter = counter + 1,
        lastcol = List.Last(Table.ColumnNames( ExpandTable)),
        LastColList = Table.Column( ExpandTable as table, lastcol) as list,
        StopIfNull = List.MatchesAll(LastColList, each _ = null)
      in
          if StopIfNull = true then 
           ExpandTable 
          else 
            @explode(
                ExpandTable, 
                TableMapping, 
                "Explosion_" & Number.ToText(counter), 
                KeyMappingColumnName, 
                ResultMappingColumnName,
                QuantityColumnName  as text,
                counter as number
              ),
    Output = explode(
        TableName, 
        TableMapping, 
        SourceColumnName, 
        KeyMappingColumnName, 
        ResultMappingColumnName,
        QuantityColumnName  as text, 
        0
      )

  in
Output
