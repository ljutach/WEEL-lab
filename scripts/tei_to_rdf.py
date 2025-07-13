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
ONTO = Namespace("http://purl.org/wittgenstein/ont#")
EX = Namespace("http://example.org/resource/")  # for local URIs

# Init RDF Graph
g = Graph()
g.bind("onto", ONTO)
g.bind("ex", EX)

# Helper: get attribute with namespace
def get_attr(el, attr):
    return el.attrib.get(f"{{{NS['xml']}}}{attr}")

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

# # Process Perspectives
# for persp in root.findall(".//tei:*[@ana='onto:Perspective']", NS):
#     pid = get_attr(persp, "id") or "no_id"
#     uri = EX[pid]
#     g.add((uri, RDF.type, ONTO.Perspective))
#     if "ref" in persp.attrib:
#         g.add((uri, ONTO.claimedBy, EX[persp.attrib["ref"].strip("#")]))
#     if "source" in persp.attrib:
#         g.add((uri, ONTO.hasSource, EX[persp.attrib["source"].strip("#")]))
#     content = "".join(persp.itertext()).strip()
#     g.add((uri, RDFS.comment, Literal(content)))

# # Process Metaphors
# for meta in root.findall(".//tei:*[@ana='onto:Metaphor']", NS):
#     mid = get_attr(meta, "id") or "no_id"
#     uri = EX[mid]
#     g.add((uri, RDF.type, ONTO.Metaphor))
#     content = "".join(meta.itertext()).strip()
#     g.add((uri, RDFS.comment, Literal(content)))
#     # Link to point if available
#     if "corresp" in meta.attrib:
#         for p in meta.attrib["corresp"].strip().split():
#             g.add((uri, ONTO.exemplifies, EX[p.strip("#")]))

# Serialize RDF
g.serialize("rdf/wittgenstein_output.ttl", format="turtle")
print("RDF created as wittgenstein_output.ttl")
