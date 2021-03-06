xquery version "1.0-ml";
module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";

import module namespace domain  = "http://xquerrail.com/domain"      at "/_framework/domain.xqy";
import module namespace model   = "http://xquerrail.com/model/base"  at "/_framework/base/base-model.xqy";

declare namespace metadata = "http://marklogic.com/metadata";

declare option xdmp:mapping "false";

declare variable $TEST-DIRECTORY := "/test/program/";

declare variable $TEST-MODEL := 
  <model name="program" persistence="directory" label="Program" key="id" keyLabel="id" xmlns="http://xquerrail.com/domain">
    <directory>{$TEST-DIRECTORY}</directory>
    <attribute name="id" identity="true" type="identity" label="Id">
      <navigation searchable="true"></navigation>
    </attribute>
    <container name="container1" label="Container #1">
      <element name="field1" type="string" label="Field #1">
        <navigation exportable="true" searchable="true" facetable="false" metadata="true" searchType="range"></navigation>
      </element> 
      <element name="field2" type="string" label="Field #2">
        <navigation exportable="false" searchable="true" facetable="false" metadata="true" searchType="range"></navigation>
      </element>
    </container>
    <element name="field3" type="string" label="Field #3">
      <navigation exportable="true" searchable="true" facetable="false" metadata="true" searchType="range"></navigation>
    </element> 
  </model>
;

declare variable $TEST-DOCUMENTS :=
(
  map:new((
    map:entry("container1.field1", "oscar"),
    map:entry("container1.field2", "best actor"),
    map:entry("field3", "GARY")
  )),
  map:new((
    map:entry("container1.field1", "oscar"),
    map:entry("container1.field2", "best actor"),
    map:entry("field3", "gary")
  ))
);

declare variable $TEST-IMPORT :=
<results>
<header>
  <program>
    <id>Id</id>
    <container1.field1>Field #1</container1.field1>
    <field3>Field #3</field3>
  </program>
</header>
<body>
  <program id="1234567890" xmlns="http://marklogic.com/metadata">
    <container1.field1>noah</container1.field1>
  </program>
</body>
</results>;

declare %private function create-items() as empty-sequence() {
  let $_ := for $doc in $TEST-DOCUMENTS
    return model:create($TEST-MODEL, $doc)
  return ()
};

declare %test:setup function setup() as empty-sequence()
{
  (
    xdmp:log("*** SETUP ***"),
    create-items()
  )
};

declare %test:teardown function teardown() as empty-sequence()
{
  (
    xdmp:log("*** TEARDOWN ***"),
    xdmp:directory-delete($TEST-DIRECTORY)
   )
};

declare %test:ignore function test-import() as item()*
{
  let $_ := model:import($TEST-MODEL, $TEST-IMPORT)
  let $params := map:new((
    map:entry("container1.field1", "oscar")
  ))
  let $doc := model:get($TEST-MODEL, $params)
  return 
  (
    assert:not-empty($doc),
    assert:equal($doc/*:container1/*:field1/text(), "noah")
  )
};

