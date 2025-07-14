import xml.etree.ElementTree as ET
from rdflib import Graph, Namespace, URIRef, Literal
from rdflib.namespace import RDF, RDFS, XSD

# Load TEI
tei_file = "data/Ts-207_Clarino-pruned.xml"  # replace with your actual TEI file
tree = ET.parse(tei_file)
root = tree.getroot()

# Namespaces
NS = {
    "tei": "http://www.tei-c.org/ns/1.0",
    "xml": "http://www.w3.org/XML/1998/namespace"
}

# Ontology Namespace (from your OWL file)
ONTO = Namespace("https://ljutach.github.io/WEEL-lab/rdf/wittgenstein_ontology.owl#")
EX = Namespace("https://ljutach.github.io/WEEL-lab/resource/")  # for local URIs

# Init RDF Graph
g = Graph()
g.bind("onto", ONTO)
g.bind("ex", EX)

# Helper: get attribute with namespace
def get_attr(el, attr):
    return el.attrib.get(f"{{{NS['xml']}}}{attr}")


# Process Persons
for person in root.findall(".//tei:persName", NS):
    person_id = get_attr(person, "id")
    if not person_id:
        continue  # Skip unnamed persons
    person_uri = EX[person_id]
    g.add((person_uri, RDF.type, ONTO.Person))
    
    # Add label from content
    label = "".join(person.itertext()).strip()
    if label:
        g.add((person_uri, RDFS.label, Literal(label)))

# Process Fields
for field in root.findall(".//tei:term", NS):
    field_id = get_attr(field, "id")
    if not field_id:
        continue  # skip terms without xml:id

    field_uri = EX[field_id]
    g.add((field_uri, RDF.type, ONTO.Field))  # class Field from ontology

    # Add literal label or description
    content = "".join(field.itertext()).strip()
    if content:
        g.add((field_uri, RDFS.label, Literal(content)))


# Process ExternalSource
for source in root.findall(".//tei:bibl[@ana='onto:WittgensteinExternalSource']", NS):
    source_id = get_attr(source, "id")
    if not source_id:
        continue  # skip sources without xml:id

    source_uri = EX[source_id]
    g.add((source_uri, RDF.type, ONTO.WittgensteinExternalSource))  # the correct class

    # Link to author if @ref is present (e.g., ref="#shakespeare")
    ref = source.attrib.get("ref")
    if ref:
        g.add((source_uri, ONTO.hasAuthor, EX[ref.strip("#")]))

    # Add literal label from text content
    content = "".join(source.itertext()).strip()
    if content:
        g.add((source_uri, RDFS.label, Literal(content)))


# Process Exemplifications
for ex in root.findall(".//tei:seg[@ana='onto:Exemplification']", NS):
    ex_id = get_attr(ex, "id") or "no_id"
    ex_uri = EX[ex_id]
    g.add((ex_uri, RDF.type, ONTO.Exemplification))

    # Link to the entity it exemplifies via @corresp
    corresp = ex.attrib.get("corresp")
    if corresp:
        for c in corresp.strip().split():
            g.add((ex_uri, ONTO.exemplifies, EX[c.strip("#")]))

    # Literal content of the example
    content = "".join(ex.itertext()).strip()
    if content:
        g.add((ex_uri, RDFS.comment, Literal(content)))


# Process Metaphors
for meta in root.findall(".//tei:seg[@ana='onto:Metaphor']", NS):
    meta_id = get_attr(meta, "id") or "no_id"
    meta_uri = EX[meta_id]
    g.add((meta_uri, RDF.type, ONTO.Metaphor))

    # Link to the point it exemplifies (e.g., corresp="#clm2")
    corresp = meta.attrib.get("corresp")
    if corresp:
        for ref in corresp.strip().split():
            g.add((meta_uri, ONTO.exemplifies, EX[ref.strip("#")]))

    # Literal content of the metaphor
    content = "".join(meta.itertext()).strip()
    if content:
        g.add((meta_uri, RDFS.comment, Literal(content)))



# Process Points
for point in root.findall(".//tei:*[@ana='onto:Point']", NS):
    point_id = get_attr(point, "id") or "no_id"
    point_uri = EX[point_id]
    g.add((point_uri, RDF.type, ONTO.Point))

    # claimedBy (e.g. ref="#wittgenstein")
    ref = point.attrib.get("ref")
    if ref:
        g.add((point_uri, ONTO.claimedBy, EX[ref.strip("#")]))

    # isAbout (e.g. corresp="#fld1")
    corresp = point.attrib.get("corresp")
    if corresp:
        for c in corresp.strip().split():
            g.add((point_uri, ONTO.isAbout, EX[c.strip("#")]))

    # literal value
    content = "".join(point.itertext()).strip()
    g.add((point_uri, RDFS.comment, Literal(content)))    

# Process Perspectives
for persp in root.findall(".//tei:*[@ana='onto:Perspective']", NS):
    persp_id = get_attr(persp, "id") or "no_id"
    persp_uri = EX[persp_id]
    g.add((persp_uri, RDF.type, ONTO.Perspective))

    # claimedBy (e.g., ref="#wittgenstein")
    ref = persp.attrib.get("ref")
    if ref:
        g.add((persp_uri, ONTO.claimedBy, EX[ref.strip("#")]))

    # isAbout (e.g., corresp="#fld1")
    corresp = persp.attrib.get("corresp")
    if corresp:
        for c in corresp.strip().split():
            g.add((persp_uri, ONTO.isAbout, EX[c.strip("#")]))

    # literal content
    content = "".join(persp.itertext()).strip()
    if content:
        g.add((persp_uri, RDFS.comment, Literal(content)))



# Serialize RDF
g.serialize("rdf/wittgenstein_output.ttl", format="turtle")
print("RDF created as wittgenstein_output.ttl")


# === JSON export with flattened literals ===
import json

nodes = {}
edges = {}

# 1. Map rdfs:label or rdfs:comment to URIs
label_map = {}
for s, p, o in g:
    if p in (RDFS.label, RDFS.comment) and isinstance(o, Literal):
        label_map[str(s)] = str(o)

# 2. Construct nodes and edges with flattened labels
for s, p, o in g:
    subj_uri = str(s)
    pred = str(p)

    # Subject label (if available), else ID
    subj_label = label_map.get(subj_uri, subj_uri.split("/")[-1])
    if subj_label not in nodes:
        nodes[subj_label] = {
            "id": subj_label,
            "label": subj_label
        }

    # Object
    if isinstance(o, Literal):
        obj_label = str(o)
        if obj_label not in nodes:
            nodes[obj_label] = {
                "id": obj_label,
                "label": obj_label,
                "type": "literal"
            }
        target = obj_label

    else:
        obj_uri = str(o)
        obj_label = label_map.get(obj_uri, obj_uri.split("/")[-1])
        if obj_label not in nodes:
            nodes[obj_label] = {
                "id": obj_label,
                "label": obj_label
            }
        target = obj_label

    # Add the edge
    edges.setdefault((subj_label, pred.split("#")[-1], target), {
        "source": subj_label,
        "label": pred.split("#")[-1],
        "target": target
    })

# 3. Serialize to JSON
output = {
    "nodes": list(nodes.values()),
    "edges": list(edges.values())
}

with open("json/graph_data.json", "w", encoding="utf-8") as f:
    json.dump(output, f, indent=2, ensure_ascii=False)

print("Graph JSON created with flattened literals as rdf/graph_data1.json")
