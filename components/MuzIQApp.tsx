import React, { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import ReactFlow, { MiniMap, Controls, Background } from "reactflow";
import "reactflow/dist/style.css";
import genreData from "../data/genres.json";

const createNodesFromGenres = (data) =>
  data.map((genre, index) => ({
    id: genre.id,
    data: { label: genre.name },
    position: { x: index * 200, y: 100 },
    style: { borderRadius: "12px", padding: "10px", background: "white" }
  }));

const nodes = createNodesFromGenres(genreData);

const edges = genreData.flatMap((genre) =>
  genre.influences?.map((influence) => ({
    id: `${influence}->${genre.id}`,
    source: influence,
    target: genre.id,
    animated: true
  })) || []
);

export default function MuzIQApp() {
  const [selectedGenre, setSelectedGenre] = useState(null);

  const handleNodeClick = (event, node) => {
    const genre = genreData.find((g) => g.id === node.id);
    if (!genre) {
      console.warn(`Genre with ID '${node.id}' not found.`);
      return;
    }
    setSelectedGenre(genre);
  };

  return (
    <div className="p-4">
      <Card className="mb-4">
        <CardContent>
          {selectedGenre ? (
            <div>
              <h2 className="text-xl font-bold mb-2">{selectedGenre.name}</h2>
              <p>📍 {selectedGenre.region}</p>
              <p>📅 {selectedGenre.era}</p>
              <p>
                <strong>Influences:</strong>{" "}
                {selectedGenre.influences?.join(", ")}
              </p>
              <p>
                <strong>Descendants:</strong>{" "}
                {selectedGenre.descendants?.join(", ")}
              </p>
              <p>
                <strong>Artists:</strong> {selectedGenre.artists?.join(", ")}
              </p>
              <p>
                <strong>Key Elements:</strong>{" "}
                {selectedGenre.elements?.join(", ")}
              </p>
              <div className="mt-4">
                {selectedGenre.tracks?.map((track, i) => (
                  <div key={i} className="mb-2">
                    <p>
                      <strong>{track.artist}</strong> – {track.title}
                    </p>
                    <Button
                      onClick={() =>
                        window.open(track.spotify_url, "_blank")
                      }
                    >
                      Listen on Spotify
                    </Button>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <p>
              Click on a genre node in the graph to explore its evolution,
              influences, and example tracks. Hover over nodes for more info.
            </p>
          )}
        </CardContent>
      </Card>
      <div style={{ height: "500px" }}>
        <ReactFlow
          nodes={nodes}
          edges={edges}
          onNodeClick={handleNodeClick}
          fitView
        >
          <MiniMap />
          <Controls />
          <Background />
        </ReactFlow>
      </div>
    </div>
  );
}