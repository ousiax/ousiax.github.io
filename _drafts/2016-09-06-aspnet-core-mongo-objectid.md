---
layout: post
title: "aspnet-core-mongo-objectId"
date: 2016-09-06 16-23-25 +0800
categories: ['asp.net']
tags: ['asp.net']
disqus_identifier: 268773126244055759242482334335460547794
---

*ObjectIdModelBinder.cs*

```cs
/// <summary>
/// <see cref="IModelBinder"/> implementation for binding <see cref="ObjectId"/>.
/// </summary>
public sealed class ObjectIdModelBinder : IModelBinder
{
    /// <inheritdoc />
    public Task BindModelAsync(ModelBindingContext bindingContext)
    {
        if (bindingContext == null)
        {
            throw new ArgumentNullException(nameof(bindingContext));
        }

        var valueProviderResult = bindingContext.ValueProvider.GetValue(bindingContext.ModelName);
        if (valueProviderResult == ValueProviderResult.None)
        {
            // no entry
            return TaskCache.CompletedTask;
        }

        bindingContext.ModelState.SetModelValue(bindingContext.ModelName, valueProviderResult);

        var value = valueProviderResult.FirstValue;

        try
        {
            var model = ObjectId.Parse(value);
            bindingContext.Result = ModelBindingResult.Success(model);
            return TaskCache.CompletedTask;
        }
        catch (Exception exception)
        {
            bindingContext.ModelState.TryAddModelError(
                bindingContext.ModelName,
                exception,
                bindingContext.ModelMetadata);
            return TaskCache.CompletedTask;
        }
    }
}
```

*ObjectIdModelBinderProvider.cs*

```cs
/// <summary>
/// An <see cref="IModelMetadataProvider"/> for <see cref="ObjectId"/>.
/// </summary>
public class ObjectIdModelBinderProvider : IModelBinderProvider
{
    /// <inheritdoc />
    public IModelBinder GetBinder(ModelBinderProviderContext context)
    {
        if (context == null)
        {
            throw new ArgumentNullException(nameof(context));
        }

        if (context.Metadata.ModelType == typeof(ObjectId))
        {
            return new ObjectIdModelBinder();
        }

        return null;
    }
}
```

*Startup.cs*

```cs
            services.AddMvc(o =>
            {
                o.ModelBinderProviders.Insert(0, new ObjectIdModelBinderProvider());
            })
```
