RelationType.seed(:id,
  { id: 1,  title: 'partners with', title_reverse: 'partners_with',  relation_category: 1},
  { id: 2,  title: 'contains'     , title_reverse: 'belongs to',     relation_category: 2},
  { id: 3,  title: 'implements'   , title_reverse: 'implemented by', relation_category: 3},
  { id: 4,  title: 'funds'        , title_reverse: 'funded by',      relation_category: 3},
  { id: 5,  title: 'wrote'        , title_reverse: 'written by',     relation_category: 4},
  { id: 6,  title: 'developed'    , title_reverse: 'developed by',   relation_category: 4},
  { id: 7,  title: 'approved'     , title_reverse: 'approved by',    relation_category: 4},
  { id: 8,  title: 'signed'       , title_reverse: 'signed by',      relation_category: 4},
  { id: 9,  title: 'contains'     , title_reverse: 'is part of',     relation_category: 5},
  { id: 10, title: 'produced'     , title_reverse: 'was supported by', relation_category: 6},
  { id: 11, title: 'created'      , title_reverse: 'was supported by', relation_category: 6},
  { id: 12, title: 'developed'    , title_reverse: 'was supported by', relation_category: 6},
  { id: 13, title: 'supported'    , title_reverse: 'was supported by', relation_category: 6},
  { id: 14, title: 'contains'     , title_reverse: 'belongs to',       relation_category: 7}
)

puts ''
puts '****************************************************************************'
puts '*                                                                          *'
puts '* Relation types created                                                   *'
puts '*                                                                          *'
puts '****************************************************************************'