import React, { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import ReactFlow, { MiniMap, Controls, Background } from "reactflow";
import "reactflow/dist/style.css";
import genreData from "../data/genres.json";

const nodes = genreData.map((genre, index) => ({
  id: genre.id,
  data: { label: genre.name },
  position: { x: index * 200, y: 100 },
  style: { borderRadius: "12px", padding: "10px", background: "white" }
}));

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
    setSelectedGenre(genre);
  };

  return (
    <div className="w-full h-screen flex">
      <div className="w-2/3 h-full">
        <ReactFlow nodes={nodes} edges={edges} onNodeClick={handleNodeClick} fitView>
          <MiniMap />
          <Controls />
          <Background />
        </ReactFlow>
      </div>
      <div className="w-1/3 h-full overflow-y-auto p-4 bg-gray-50">
        {selectedGenre ? (
          <Card>
            <CardContent>
              <h2 className="text-xl font-bold mb-2">{selectedGenre.name}</h2>
              <p className="text-sm text-muted">📍 {selectedGenre.region}</p>
              <p className="text-sm text-muted">📅 {selectedGenre.era}</p>
              <div className="mt-4">
                <p><strong>Influences:</strong> {selectedGenre.influences?.join(", ")}</p>
                <p><strong>Descendants:</strong> {selectedGenre.descendants?.join(", ")}</p>
                <p><strong>Artists:</strong> {selectedGenre.artists?.join(", ")}</p>
                <p><strong>Key Elements:</strong> {selectedGenre.elements?.join(", ")}</p>
              </div>
              <div className="mt-4">
                {selectedGenre.tracks?.map((track, i) => (
                  <div key={i}>
                    <p><strong>{track.artist} – {track.title}</strong></p>
                    <a href={track.spotify_url} target="_blank" rel="noopener noreferrer">
                      <Button variant="link">Listen on Spotify</Button>
                    </a>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        ) : (
          <p>Select a genre node to explore its evolution and influence.</p>
        )}
      </div>
    </div>
  );
}