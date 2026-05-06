import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import crypto from "crypto";

const s3 = new S3Client({});

const allowedExtensions = ["jpg", "jpeg", "png", "gif", "webp"];

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      "content-type": "application/json",
      "access-control-allow-origin": "*"
    },
    body: JSON.stringify(body)
  };
}

export const handler = async (event) => {
  try {
    const bucketName = process.env.S3_BUCKET;
    const uploadPrefix = process.env.UPLOAD_PREFIX || "uploads/";
    const maxFileSizeMb = Number(process.env.MAX_FILE_SIZE_MB || "10");

    if (!event.body) {
      return response(400, {
        message: "No se recibió contenido en la solicitud."
      });
    }

    let payload;

    try {
      payload = JSON.parse(event.body);
    } catch {
      return response(400, {
        message: "El cuerpo debe enviarse en formato JSON con imagen en base64."
      });
    }

    const filename = payload.filename;
    const contentType = payload.contentType;
    const imageBase64 = payload.imageBase64;

    if (!filename || !contentType || !imageBase64) {
      return response(400, {
        message: "Faltan campos requeridos: filename, contentType o imageBase64."
      });
    }

    const extension = filename.split(".").pop().toLowerCase();

    if (!allowedExtensions.includes(extension)) {
      return response(415, {
        message: "Formato no permitido. Use jpg, png, gif o webp."
      });
    }

    const imageBuffer = Buffer.from(imageBase64, "base64");
    const maxBytes = maxFileSizeMb * 1024 * 1024;

    if (imageBuffer.length > maxBytes) {
      return response(413, {
        message: `La imagen supera el tamaño máximo permitido de ${maxFileSizeMb} MB.`
      });
    }

    const objectKey = `${uploadPrefix}${crypto.randomUUID()}-${filename}`;

    await s3.send(
      new PutObjectCommand({
        Bucket: bucketName,
        Key: objectKey,
        Body: imageBuffer,
        ContentType: contentType
      })
    );

    return response(201, {
      message: "Imagen subida correctamente.",
      bucket: bucketName,
      key: objectKey
    });
  } catch (error) {
    console.error("Error en upload-lambda:", error);

    return response(500, {
      message: "Error interno al subir la imagen.",
      error: error.message
    });
  }
};