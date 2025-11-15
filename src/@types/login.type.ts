import { z } from 'zod';

export const loginSchema = z.object({
    email: z.email("O e-mail informado é inválido!"),
    senha: z.string()
        .min(3, "Deve possuir ao menos 3 caracteres")
        .max(20, "Deve possuir no máximo 20 caracteres"),
});

export type Login = z.infer<typeof loginSchema>