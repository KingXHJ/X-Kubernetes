## Secret
Secret的主要作用时保管私密数据，比如密码、OAuth Tokens、SSH Keys等信息。将这些私密信息放在Secret对象中比直接放在Pod或Docker Image中更安全，也更便于使用和分发

![secret.yaml](./secret.yaml)

Secert的使用方式：
1. 创建Pod时，通过为Pod指定Service Account来自动使用该Secret
1. 通过挂载该Secret到Pod来使用它
    ![mount-secret.yaml](./mount-secret.yaml)
1. 在Docker镜像下载时使用，通过指定Pod的spc.ImagePullSecrets来使用它
    ![imagepullsecrets.yaml](./imagepullsecrets.yaml)



