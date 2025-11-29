import { CameraCapturedPicture, CameraType, CameraView, useCameraPermissions } from 'expo-camera';
import { createAssetAsync, usePermissions } from 'expo-media-library';
import { useRef, useState } from 'react';
import { Button, Image, Text, View } from 'react-native';

export default function Camera() {
    const [facing, setFacing] = useState<CameraType>('back')
    const [permission, requestPermission] = useCameraPermissions();
    const [ultimaFoto, setUltimaFoto] = useState<CameraCapturedPicture | null>(null)

    const [permissionGaleria, requestPermissionGaleria] = usePermissions()

    const cameraRef = useRef<CameraView | null>(null);

    if (!permission) {
        return <View>
            <Text>Sem permissão para acesso à câmera.</Text>
        </View>
    }

    if (!permission.granted) {
        requestPermission()
    }

    const inverterCamera = () => {
        setFacing(facing === 'back' ? 'front' : 'back');
    }

    const tirarFoto = async () => {
        if (cameraRef && cameraRef.current) {
            const foto = await cameraRef.current.takePictureAsync({
                quality: 1,
                base64: true,
                isImageMirror: true,
            });

            if (foto) {
                setUltimaFoto(foto);
                await salvarFoto(foto);
            }
        }
    }

    const salvarFoto = async (foto: CameraCapturedPicture) => {
        if (!permissionGaleria || !permissionGaleria.granted) {
            const response = await requestPermissionGaleria()
            
            if (!response.granted) {
                return;
            }
        }

        await createAssetAsync(foto.uri);
    }

    return (
        <View>
            <CameraView
                style={{ width: '100%', height: 400 }}
                facing={facing}
                ref={cameraRef}
            />
            <Button title='Inverter câmera' onPress={inverterCamera} />
            <Button title='Tirar foto' color={'green'} onPress={tirarFoto} />

            {ultimaFoto && (
                <View>
                    <Image source={{ uri: ultimaFoto.uri }} width={500} height={500} />
                </View>
            )}
        </View>
    )

}