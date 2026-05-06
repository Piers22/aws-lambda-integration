import { S3Client, GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import path from "path";

const s3 = new S3Client({});

async function streamToBuffer(stream) {
  const chunks = [];

  for await (const chunk of stream) {
    chunks.push(chunk);
  }

  return Buffer.concat(chunks);
}

function getProcessedKey(originalKey, processedPrefix) {
  const filename = path.basename(originalKey);
  const cleanName = filename.replace(/\.[^/.]+$/, "");
  return `${processedPrefix}${cleanName}_processed.png`;
}

export const handler = async (event) => {
  console.log("Evento recibido:", JSON.stringify(event));

  const processedPrefix = process.env.PROCESSED_PREFIX || "processed/";

  for (const record of event.Records || []) {
    const body = JSON.parse(record.body);

    for (const s3Record of body.Records || []) {
      const bucketName = s3Record.s3.bucket.name;
      const originalKey = decodeURIComponent(
        s3Record.s3.object.key.replace(/\+/g, " ")
      );

      const processedKey = getProcessedKey(originalKey, processedPrefix);

      const originalObject = await s3.send(
        new GetObjectCommand({
          Bucket: bucketName,
          Key: originalKey
        })
      );

      const imageBuffer = await streamToBuffer(originalObject.Body);

      await s3.send(
        new PutObjectCommand({
          Bucket: bucketName,
          Key: processedKey,
          Body: imageBuffer,
          ContentType: "image/png"
        })
      );

      console.log(`Imagen procesada: ${originalKey} -> ${processedKey}`);
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Procesamiento finalizado."
    })
  };
};